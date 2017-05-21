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

第二个回调函数 **fnError** 是错误回调，通过下面的代码来调用，例如 `observer.error(<message>)`

```javascript
let stream$ = Rx.Observable.create((observer) => {
   observer.error('error message');
})

stream$.subscribe(
   (data) => console.log('Data', data)),
   (error) => console.log('Error', error)
```

最后是 **fnComplete**，当流完成时调用，并且不会再发出任何值。它是通过 `observer.complete()` 来触发的，像这样：

```javascript
let stream$ = Rx.Observable.create((observer) => {
   // 多次调用 observer.next(<value>)
   observer.complete();
})
```

## Unsubscribe

目前为止，我们创建的是一个不负责任的 Observable 。在这里不负责任是指它并没有清理它自身。那么我们来看下如何做到这点：

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
  subscription.unsubscribe() // 在这我们调用了清理函数

}, 3000)
```

所以你要确保
* 定义一个清理函数
* 通过调用 `subscription.unsubscribe()` 隐式的调用清理函数
