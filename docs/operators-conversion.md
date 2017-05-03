# 转换操作符

这个类别的全部是展示以某些东西为基础来创建 Observables 是多么的容易，因此他们可以和操作符配合的很好，而不在乎是怎样的构造，从而实现丰富的组合。

## from

在 RxJS 4中，存在一些类似名称的操作符，例如 `fromArray()`、`from()`、`fromPromise()` 等等。所有这些 `fromXXX` 的操作符现在全由 `from()` 接管了。来看一些示例：

**老的 fromArray**

```javascript
Rx.Observable.from([2,3,4,5])
```

**老的 fromPromise**

```javascript
Rx.Observable.from(new Promise(resolve, reject) => {
  // 异步操作
  resolve( data )
})
```

## of

`of` 操作符接收x个参数，所以你可以像下面这样以任意个参数来调用它：

```javascript
Rx.Observable.of(1,2);
Rx.Observable.of(1,2,3,4);
```

## to

还存在一组操作符允许你反其道而行，也就是离开美妙的 observables 世界并回到更原始的状态，像这样：

```javascript
let promise = Rx.Observable.of(1,2).toPromise();
promise.then(data => console.log('Promise', data));
```
