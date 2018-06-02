# Observable Anatomy

An observable's subscribe method has the following signature

```
stream.subscribe(fnValue, fnError, fnComplete)
```

The first one is being demonstrated below **fnValue**

```
import { Observable } from 'rxjs';

let stream$ = Observable.create((observer) => {
  observer.next(1)
});

stream$.subscribe((data) => {
  console.log('Data', data);
})

// 1
```

When `observer.next(<value>)` is being called the `fnValue` is being invoked.

The second callback **fnError** is the error callback and is being invoked by the following code, i.e `observer.error(<message>)`

```
let stream$ = Rx.Observable.create((observer) => {
   observer.error('error message');
})

stream$.subscribe(
   (data) => console.log('Data', data),
   (error) => console.log('Error', error))
```

Lastly we have the **fnComplete** and it should be invoked when a stream is done and has no more values to emit. It is triggered by a call to `observer.complete()` like so:

```
let stream$ = Rx.Observable.create((observer) => {
   // x calls to observer.next(<value>)
   observer.complete();
})
```

## Unsubscribe

So far we have been creating an irresponsible Observable, irresponsible in the sense that it doesn't clean up after itself. So let's look at how to do that:

```
let stream$ = Observable.create((observer) => {
  let i = 0;
  let id = setInterval(() => {
    observer.next(i++);
  },1000)

  return function(){
    clearInterval( id );
  }
})

let subscription = stream$.subscribe((value) => {
  console.log('Value', value)
});

setTimeout(() => {
  subscription.unsubscribe() // here we invoke the cleanup function

}, 3000)
```

So ensure that you

* Define a function that cleans up 
* Implicitely call that function by calling `subscription.unsubscribe()`  



