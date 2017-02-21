An observable has the following signature

```
stream(fnValue, fnError, fnComplete)
```

The first one is being demonstrated below **fnValue**

```
let stream$ = Rx.Observable.create((observer) => {
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
   (data) => console.log('Data', data)),
   (error) => console.log('Error', error) 
```

Lastly we have the **fnComplete** and it should be invoked when a stream is done and has no more values to emit. It is triggered by a call to `observer.complete()` like so:

```
let stream$ = Rx.Observable.create((observer) => {
   // x calls to observer.next(<value>)
   observer.complete();
})
```

