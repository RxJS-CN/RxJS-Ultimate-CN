# Observable 剖析

Observable 的 subscribe 方法签名如下：

```javascript
stream.subscribe(fnValue, fnError, fnComplete)
```

下面所演示的是第一个参数 **fnValue**

```javascript
let stream$ = Rx.Observable.create((observer) => {
  observer.next(1)
});

stream$.subscribe((data) => {
  console.log('Data', data);
})

// 1
```

当执行 `observer.next(<value>)` 时， `fnValue` 就会被调用。

第二个回调函数 **fnError** 是异常回调，通过下面的代码来调用，例如 `observer.error(<message>)`

```javascript
let stream$ = Rx.Observable.create((observer) => {
   observer.error('error message');
})

stream$.subscribe(
   (data) => console.log('Data', data)),
   (error) => console.log('Error', error)
```

Lastly we have the **fnComplete** and it should be invoked when a stream is done and has no more values to emit. It is triggered by a call to `observer.complete()` like so:

```javascript
let stream$ = Rx.Observable.create((observer) => {
   // x calls to observer.next(<value>)
   observer.complete();
})
```

## Unsubscribe

So far we have been creating an irresponsible Observable. Irresponsible in the sense that it doesn't clean up after itself. So let's look at how to that:

```javascript
let stream$ = new Rx.Observable.create((observer) => {
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
