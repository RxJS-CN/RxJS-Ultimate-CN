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
syncCode()  // emit 1
syncCode2()  // emit 2
asyncCode()  // emit 3
syncCode4()  // emit 4
```

The output could very well be

```javascript
1,2,4,3
```

Because the async method may take a long time to finish. There is really no way of knowing by looking at it when something finish. The problem is if we care about order so that we get 1,2,3,4

We might resort to a callback making it look like

```javascript
syncCode()
syncCode()2
asyncCode(()= > {
   syncCode4()
})
```

At this point it is readable, somewhat but imagine we have only async code then it might look like:

```javascript
asyncCode(() => {
   asyncCode2(() => {
     asyncCode3() => {

     }
   })
})
```

Also known as callback hell, pause for effect :)

For that reason promises started to exist so we got code looking like

```javascript
getData()
  .then(getMoreData)
  .then(getEvenMoreData)
```

This is great for Request/Response patterns but for more advanced async scenarios I dare say only Rxjs fits the bill.
