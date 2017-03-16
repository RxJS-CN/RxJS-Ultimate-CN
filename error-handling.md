#Error handling 
There are two major approaches how to handle errors in streams. You can retry your stream and how it eventually will work or you can take the error and transform it.

## Retry - how bout now? 
This approach makes sense when you believe the error is temporary for some reason. Usually *shaky connections* is a good candidate for this. With a *shaky connection* the endpoint might be there to answer like for example every 5th time you try. Point is the first time you try it *might* fail, but retrying x times, with a certain time between attempts, will lead to the endpoint finally answering.

### retry
TODO
### retryWhen
TODO

## Transform - nothing to see here folks
This approach is when you get an error and you choose to remake it into a valid Observable.

So lets exemplify this by creating an Observable who's mission in life is to fail miserably

```
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
```
let errorPatched$ = error$.catch(err => { return Rx.Observable.of('Patched' + err) });
errorPatched$.subscribe((data) => console.log(data) );
```
As you can see `patching it` with `.catch()` and returning a new Observable *fixes* the stream. Question is if that is what you want. Sure the stream survives and reaches completion and can emit any values that happened after the point of crash. 

If this is not what you want then maybe the Retry approach above suits you better, you be the judge.

### What about multiple streams?
You didn't think it would be that easy did you? Usually when coding Rxjs code you deal with more than one stream and using `catch()` operator approach is great if you know where to place your operator.

```
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
Care to guess what happened?
1) crash + values is emitted + complete
2) crash + values is emitted
3) crash only is emitted

Sadly 3) is what happens. Which means we have virtually no handling of the error.

**Lets patch it**
S we need to patch the error. We do patching with `catch()` operator. Question is where?

Let's try this?

```
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
In this case we get 'crash' and 'patchedMerged completed'. Ok so we reach complete but it still doesn't give us the values from `goodStream$`.
So better approach but still not good enough.

**Patch it better**
So adding the `catch()` operator after the `merge()` ensured the stream completed but it wasn't good enough. Let's try to change the placement of `catch()`, pre merge.

```
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

**GOTCHA**
It matters where the `catch()` is placed.

#### Survival of the fittest
There is another scenario that might be of interest. The above scenario assumes you want everything emitted, error messages, values, everything.

What if that is not the case, what if you only care about values from streams that behave? Let's say thats your case, there is an operator for that `onErrorResumeNext()`

```
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


