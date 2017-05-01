# Observable vs Promise

我们来直奔主题。我们创建了一个叫为 Observable 的东西。它是一个异步的概念，与 Promise 非常相似，一旦数据达到就可以触发监听。

```javascript
let stream$ = Rx.Observable.from([1,2,3])

stream$.subscribe( (value) => {
   console.log('Value',value);
})

// 1,2,3
```

如果使用 Promise 的话，相对应的写法如下：

```javascript
let promise = new Promise((resolve, reject) => {
   setTimeout(()=> {
      resolve( [1,2,3] )
   })

})

promise.then((value) => {
  console.log('Value',data)
})
```

Promises 欠缺如下能力：
* 不能生产多个值
* 不能重试
* 不能真正地玩转其它异步思想
