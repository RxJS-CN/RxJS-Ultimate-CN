# Async code 
Async code is code that isn't done immediately when being called.

```
setTimeout(() => {
  console.log('do stuff');
}, 3000 )
```

3s seconds in the future the timeout is done and `do stuff` is echoed to the screen. We can see that the anonymous function we provide is being triggered when time has passed. Now for another more revealing example:

```
doWork( () => {
  console.log('call me when done');
})
```

```
function doWork(cb){
   setTimeout( () => {
     cb();
   }, 3000)
}
```



