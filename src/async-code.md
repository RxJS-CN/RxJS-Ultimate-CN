# Async code

Async code is code that isn't done immediately when being called.

```javascript
setTimeout(() => {
  console.log('do stuff');
}, 3000 )
```

3s seconds in the future the timeout is done and `do stuff` is echoed to the screen. We can see that the anonymous function we provide is being triggered when time has passed. Now for another more revealing example:

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

Other example of callback code are events here demonstrated by a `jQuery` example

```javascript
input.on('click', () => {

})
```

The gist of callbacks and async in general is that one or more methods are invoked sometime in the future, unknown when.

## The Problem

So we established a callback can be a timer, ajax code or even an event but what is the problem with all that?

One word **Readability**

Imagine doing the following code

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
