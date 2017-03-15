#Error handling 
There are two major approaches how to handle errors in streams. You can retry your stream and how it eventually will work or you can take the error and transform it.

## Retry - how bout now? 
This approach makes sense when you believe the error is temporary for some reason. Usually *shaky connections* is a good candidate for this. With a *shaky connection* the endpoint might be there to answer like for example every 5th time you try. Point is the first time you try it *might* fail, but retrying x times, with a certain time between attempts, will lead to the endpoint finally answering.

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

