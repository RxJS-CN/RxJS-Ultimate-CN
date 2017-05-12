# Error handling

There are two major approaches how to handle errors in streams. You can retry your stream and how it eventually will work or you can take the error and transform it.

## Retry - how bout now?

This approach makes sense when you believe the error is temporary for some reason. Usually _shaky connections_ is a good candidate for this. With a _shaky connection_ the endpoint might be there to answer like for example every 5th time you try. Point is the first time you try it _might_ fail, but retrying x times, with a certain time between attempts, will lead to the endpoint finally answering.

### retry

The `retry()` operator lets us retry the whole stream, value for value x number of times having a signature like this :

```javascript
retry([times])
```

The important thing to note with the `retry()` operator is that it delays when the error callback is being called. Given the following code the error callback is being hit straight away:

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

The stream effectively dies when the error callback is being hit and this is where the `retry()` operator comes in. By appending it like so:

```javascript
let stream$ = Rx.Observable.of(1,2,3)
.map(value => {
   if(value > 2) { throw 'error' }
})
retry(5)
```

This will run the sequence of values 5 more times before finally giving up and hitting the error callback. However in this case, the way the code is written, it will just generate `1,2` five times. So our code isn't really utilizing the operator to its fullest potential. What you probably want is to be able to change something between attempts. Imagine your observable looked like this instead:

```javascript
let urlsToHit$ = Rx.Observable.of(url, url2, url3);
```

In this its clearly so that an endpoint might have answered badly or not at all on your first attempt and it makes sense to retry them x number of times.

However in the case of ajax calls, and imagining our business case is _shaky connections_ it makes no sense to do the retry immediately so we have to look elsewhere for a better operator, we need to look to `retryWhen()`

### retryWhen

A `retryWhen()` operator gives us the chance to operate on our stream and handle it appropriately

```javascript
retryWhen( stream => {
   // return it in a better condition, hopefully
})
```

Lets' write a piece of naive code for a second

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

The way it's written it will return `1` until we run out of memory cause the algorithm will always crash on the value `2` and will keep retrying the stream forever, due to our lack of end condition. What we need to do is to somehow say that the error is fixed. If the stream were trying to hit urls instead of emitting numbers a responding endpoint would be the fix but in this case we have to write something like this:

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

// 0 1 'wait 200ms' retrying the whole sequence 0 1 2 3 4
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
