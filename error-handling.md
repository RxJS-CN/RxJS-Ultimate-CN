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
