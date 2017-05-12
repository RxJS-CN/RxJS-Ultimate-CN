# 异常处理

有两种主要的方法来处理流中的错误。你可以重试流并保证流最终会正常运行，或者处理异常并进行转换。

## 重试 - 现在怎么样？

当你认为错误是由于某些原因是暂时导致的，那么这种方法是适用的。通常**不稳定的网络**是个很好的例子。当**网络不稳定**时端点可能会在你多次尝试后才能回应。要点是你的首次尝试**可能**失败，但重试x次并且在两次尝试之间有一定的时间间隔，最终端点会回应。

### retry

`retry()` 操作符可以让我们重试整个流，只接收一个参数，参数的值是要重试的次数，函数签名如下：

```javascript
retry([times])
```

重要的是要注意当异常回调被调用的话， `retry()` 操作符会有延迟。下面代码中的异常回调会立即被调用：

```javascript
let stream$ = Rx.Observable.of(1,2,3)
.map(value => {
   if(value > 2) { throw 'error' }
});

stream$.subscribe(
   data => console.log(data),
   err => console.log(err)
)
```

这个流很快的就死了，异常回调被调用，这个时候 `retry()` 操作符登场。像下面这样把它附加上即可：

```javascript
let stream$ = Rx.Observable.of(1,2,3)
.map(value => {
   if(value > 2) { throw 'error' }
})
retry(5)
```

这将运行值序列5次，最后放弃并进入异常回调。然而在这个案例中，由于编写代码的方式，它只会生成5次`1,2`。所以我们的代码并没有真正利用操作符的最大潜力。你可能想要的是能够在每次尝试之间改变一些东西。想象下你的 observable 看起来像这样：

```javascript
let urlsToHit$ = Rx.Observable.of(url, url2, url3);
```

在这一点上，它清楚地表明，在你的第一次尝试中，端点可能回应的不好，或者根本就没有回应，所以重试x次是很有用的。

然而在调用 ajax 的情况下，并想象一下我们的业务场景中**网络不稳定**，那么立即重试是没有意义的，所以我们需要再找到一个更好的操作符，那就是 `retryWhen()`

### retryWhen

`retryWhen()` 操作符让我们有机会对流进行操作并恰当地处理。

```javascript
retryWhen( stream => {
   // 希望能在更好的条件下返回
})
```

现在我们来写段简单的代码：

```javascript
let values$ = Rx.Observable
.of( 1,2,3,4 )
.map(val => {
    if(val === 2) { throw 'err'; }
    else return val;
})
.retryWhen( stream => {
    return stream;
} );

values$.subscribe(
    data => console.log('Retry when - data',data),
    err => console.error('Retry when - Err',err)
)
```

这样写的话会一直返回 `1`，直到我们用完内存为止，由于缺少结束条件，算法总是会在值`2`上崩溃，并将永远重试流。我们需要做的就是以某种方式告知异常已经修复。如果流尝试点击网址而不是发出数字，响应端点将会被压垮，所以在这种情况下，我们必须写这样的东西：

```javascript
let values$ = Rx.Observable.interval(1000).take(5);
let errorFixed = false;

values$
.map((val) => {
   if(errorFixed) { return val; }
   else if( val > 0 && val % 2 === 0) {
      errorFixed = true;
      throw { error : 'error' };

   } else {
      return val;
   }
})
.retryWhen((err) => {
    console.log('retrying the entire sequence');
    return err;
})
.subscribe((val) => { console.log('value',val) })

// 0 1 '等待200毫秒' retrying the whole sequence 0 1 2 3 4
```

This however resembles a lot of what we did with the `retry()` operator, the code above will just retry once. The real benefit is being to change the stream we return inside the `retryWhen()` namely to involve a delay like this:

```javascript
.retryWhen((err) => {
    console.log('retrying the entire sequence');
    return err.delay(200)
})
```

This ensures there is a 200ms delay before sequence is retried, which in an ajax scenario could be enough for our endpoint to get it's shit together and start responding.

**GOTCHA**

The `delay()` operator is used within the `retryWhen()` to ensure that the retry happens a while later to in this case give the network a chance to recover.

#### retryWhen with delay and no of times

So far `retry()` operator has been used when we wanted to retry the sequence x times and `retryWhen()` has been used when we wanted to delay the time between attempts, but what if we want both. Can we do that? We can. We need to think about us somehow remembering the number of attempts we have made so far. It's very tempting to introduce an external variable and keep that count, but that's not how we do things the functional way, remember side effects are forbidden. So how do we solve it? There is an operator called `scan()` that will allow us to accumulate values for every iteration. So if you use scan inside of the `retryWhen()` we can track our attempts that way:

```javascript
let ATTEMPT_COUNT = 3;
let DELAY = 1000;
let delayWithTimes$ = Rx.Observable.of(1,2,3)
.map( val => {
  if(val === 2) throw 'err'
  else return val;
})
.retryWhen(e => e.scan((errorCount, err) => {
    if (errorCount >= ATTEMPT_COUNT) {
        throw err;
    }
    return errorCount + 1;
}, 0).delay(DELAY));

delayWithTimes$.subscribe(
    val => console.log('delay and times - val',val),
    err => console.error('delay and times - err',err)
)
```

## Transform - nothing to see here folks

This approach is when you get an error and you choose to remake it into a valid Observable.

So lets exemplify this by creating an Observable who's mission in life is to fail miserably

```javascript
let error$ = Rx.Observable.throw('crash');

error$.subscribe(
  data => console.log( data ),
  err => console.log( err ),
  () => console.log('complete')
)
```

This code will only execute the error callback and NOT reach the complete callback.

### Patching it

We can patch this by introducing the `catch()` operator. It is used like this:

```javascript
let errorPatched$ = error$.catch(err => { return Rx.Observable.of('Patched' + err) });
errorPatched$.subscribe((data) => console.log(data) );
```

As you can see patching it with `.catch()` and returning a new Observable _fixes_ the stream. Question is if that is what you want. Sure the stream survives and reaches completion and can emit any values that happened after the point of crash.

If this is not what you want then maybe the Retry approach above suits you better, you be the judge.

### What about multiple streams?

You didn't think it would be that easy did you? Usually when coding Rxjs code you deal with more than one stream and using `catch()` operator approach is great if you know where to place your operator.

```javascript
let badStream$ = Rx.Observable.throw('crash');
let goodStream$ = Rx.Observable.of(1,2,3,);

let merged$ = Rx.Observable.merge(
  badStream$,
  goodStream$
);

merged$.subscribe(
   data => console.log(data),
   err => console.error(err),
   () => console.log('merge completed')
)
```

Care to guess what happened? 1) crash + values is emitted + complete 2) crash + values is emitted 3) crash only is emitted

Sadly 3) is what happens. Which means we have virtually no handling of the error.

**Lets patch it** S we need to patch the error. We do patching with `catch()` operator. Question is where?

Let's try this?

```javascript
let mergedPatched$ = Rx.Observable.merge(
    badStream$,
    goodStream$
).catch(err => Rx.Observable.of(err));

mergedPatched$.subscribe(
    data => console.log(data),
    err => console.error(err),
    () => console.log('patchedMerged completed')
)
```

In this case we get 'crash' and 'patchedMerged completed'. Ok so we reach complete but it still doesn't give us the values from `goodStream$`. So better approach but still not good enough.

**Patch it better** So adding the `catch()` operator after the `merge()` ensured the stream completed but it wasn't good enough. Let's try to change the placement of `catch()`, pre merge.

```javascript
let preMergedPatched$ = Rx.Observable.merge(
    badStream$.catch(err => Rx.Observable.of(err)),
    goodStream$
).catch(err => Rx.Observable.of(err));

preMergedPatched$.subscribe(
    data => console.log(data),
    err => console.error(err),
    () => console.log('pre patched merge completed')
)
```

And voila, we get values, our error emits its error message as a new nice Observable and we get completion.

**GOTCHA** It matters where the `catch()` is placed.

#### Survival of the fittest

There is another scenario that might be of interest. The above scenario assumes you want everything emitted, error messages, values, everything.

What if that is not the case, what if you only care about values from streams that behave? Let's say thats your case, there is an operator for that `onErrorResumeNext()`

```javascript
let secondBadStream$ = Rx.Observable.throw('bam');
let gloriaGaynorStream$ = Rx.Observable.of('I will survive');

let emitSurviving = Rx.Observable.onErrorResumeNext(
    badStream$,
    secondBadStream$,
    gloriaGaynorStream$
);

emitSurviving.subscribe(
    data => console.log(data),
    err => console.error(err),
    () => console.log('Survival of the fittest, completed')
)
```

The only thing emitted here is 'I will survive' and 'Survival of the fittest, completed'.
