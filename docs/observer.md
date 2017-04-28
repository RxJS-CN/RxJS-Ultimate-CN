# Observer (观察者)

注意下面的代码示例创建了一个 `Observable`

```javascript
let stream$ = Rx.Observables.create((observer) => {
  observer.next(4);
})
```

`create` 方法接收一个函数，该函数有一个入参 `observer` 。

Observer 只是一个拥有 `next`、`error` 和 `complete` 三个方法的普通对象而已

```javascript
observer.next(1);
observer.error('some error')
observer.complete();
```
