# 异步代码

异步代码是指当调用后不会立即完成的代码。

```javascript
setTimeout(() => {
  console.log('do stuff');
}, 3000 )
```

在 `setTimeout` 执行完3秒后 `do stuff` 会输出到控制台。我们可以看出当指定的时间过去后我们所提供的异步函数会触发。现在来看个更有启发性的示例：

```javascript
doWork( () => {
  console.log('call me when done');
})
```

```javascript
function doWork(cb){
   setTimeout( () => {
     cb();
   }, 3000)
}
```

另外一个回调函数代码的例子就是事件，这里使用了 `jQuery` 事件的写法。

```javascript
input.on('click', () => {

})
```

回调函数和异步的要点通常来说就是一个或多个函数在未来某个时间点会被调用，而这个时间点是未知的。

## 问题

所以我们已经确定了回调函数可以是定时器、ajax 代码甚至是事件，但这一切有什么问题呢？

简而言之就是 **可读性**

想象一下执行下面的代码

```javascript
syncCode()  // 输出 1
syncCode2()  // 输出 2
asyncCode()  // 输出 3
syncCode4()  // 输出 4
```

输出

```javascript
1,2,4,3
```

因为异步方法需要时间才能完成，通过看代码是没有办法知道什么时候会完成。现在问题是如果我们想要得到 1,2,3,4 就需要考虑执行的顺序。

我们可能需要调整一下回调函数的顺序，像这样：

```javascript
syncCode()
syncCode()2
asyncCode(()= > {
   syncCode4()
})
```

目前来说还是可读的，但稍微想象一下，我们的异步代码可能会变成这样：

```javascript
asyncCode(() => {
   asyncCode2(() => {
     asyncCode3() => {

     }
   })
})
```

这就是大家熟知的回调地狱(callback hell)，就此打住吧 :)

出于这个原因，于是 promises 开始出现了，之后我们就有了像这样的代码：

```javascript
getData()
  .then(getMoreData)
  .then(getEvenMoreData)
```

对于请求/响应模式，promise 已经足够好了，但对于更高级的异步场景，我敢说只有 RxJS 方能胜任。
