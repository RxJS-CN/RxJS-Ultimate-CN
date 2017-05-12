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
    return err.delay(200);
})
.subscribe((val) => { console.log('value',val) })

// 0 1 '等待200毫秒' retrying the whole sequence 0 1 2 3 4
```

然而，这与我们用 `retry()` 运算符所做的很多类似，上面的代码只会重试一次。使用 `retryWhen()` 真正的好处是可以改变操作符中返回的流，也就是这里调用的 `delay()` 操作符，像这样：

```javascript
.retryWhen((err) => {
    console.log('retrying the entire sequence');
    return err.delay(200)
})
```

这会确保在流重试前有200毫秒的延迟，如果是在 ajax 场景下，可以确保端点有足够的时间重整旗鼓，然后开始响应。

**陷阱**

在 `retryWhen()` 中使用 `delay()` 操作符来确保重试晚一点发生，在这个案例中可以给网络一个恢复的机会。

#### retryWhen 和 delay 一起使用没有次数限制

到目前为止，当我们想要重试整个流x次时使用的是 `retry()` 操作符，当我们想要在重试之间有一些延迟时间时使用的是 `retryWhen()` 操作符，但是如果我们两者都想要，可以做到吗？可以的。我们需要考虑一下要以某种方式记住到目前为止我们的尝试次数。引入一个外部变量用来保持这个数量是非常诱人的，但那不是函数式做事的方式，记住副作用是被禁止的。那么我们该如何解决呢？有一个叫做 `scan()` 的操作符，它允许我们累积每次迭代的值。所以如果在 `retryWhen()` 中使用 `scan` 的话，我们就可以追踪尝试的次数：

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

## 转换 - 这个没什么好看的

这个方法是当出现异常时你选择将错误重制成一个有效的 Observable 。

所以我们可以通过创建一个 Observable 来体现这一点，这个 Observable 的使命就是报错

```javascript
let error$ = Rx.Observable.throw('crash');

error$.subscribe(
  data => console.log( data ),
  err => console.log( err ),
  () => console.log('complete')
)
```

这段代码只会执行异常回调而不会执行完成回调。

### 修补它

我们可以通过引入 `catch()` 操作符来进行修补。它是这样使用的：

```javascript
let errorPatched$ = error$.catch(err => { return Rx.Observable.of('Patched' + err) });
errorPatched$.subscribe((data) => console.log(data) );
```

如你所见，使用 `.catch()` 进行修补并返回一个新的 Observable **修复** 流。问题是这是否是你想要的。流确实存活下来最终完成了，它可以发出崩溃之后发生的任何值。

如果这不是你想要的，那么上面的重试方法可能会更适合你，决定权在你手中。

### 多个流呢？

你没想到会这么容易吧？当你编写 RxJS 代码时，通常会处理多个流，如果你知道在哪放置 `catch()` 操作符的话，那么使用 `catch()` 的方法是很棒的。

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

猜猜发生了什么？1）异常和值都发出了，流也完成了 2）异常和值都发出了 3）只发出了异常

遗憾的是发生的是 3）。这意味着我们几乎没有处理异常。

**修复** - 所以我们需要修复异常。我们使用 `catch()` 操作符进行修复。问题在哪呢？

来试试这个?

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
