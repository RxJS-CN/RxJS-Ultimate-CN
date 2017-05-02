# 操作符

操作符赋予了 Observables 的强大。如果没有了操作符，Observables 将一无是处。RxJS 中有60+个操作符

我们来看其中一些：

## of

```javascript
let stream$ = Rx.Observable.of(1,2,3,4,5)
```

这里我们使用了创建类型的操作符创建了 observable 。它实际上是同步的，所以值立即便输出了。事实上，它允许你用逗号分隔的要发出值的列表。

## do

```javascript
let stream$ =
Rx.Observable
  .of(1,2,3)
  .do((value) => {
    console.log('emits every value')
  });
```

这是一个非常方便的操作符，用来调试 Observable 。

## filter

```javascript
let stream$ =
Rx.Observable
.of(1,2,3,4,5)
.filter((value) => {
  return value % 2 === 0;
})

// 2,4
```

So this stops certain values from being emitted

Notice however that I can add the do operator in a handy place and can still investigate all the values

```javascript
let stream$ =
Rx.Observable
.of(1,2,3,4,5)
.do((value) => {
  console.log('do',value)
})
.filter((value) => {
  return value % 2 === 0;
})

stream$.subscribe((value) => {
  console.log('value', value)
})

//  do: 1,do : 2, do : 3, do : 4, do: 5
// value : 2, 4
```
