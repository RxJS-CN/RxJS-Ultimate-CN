# 组合操作符

有一些操作符允许你组合两个及以上的 source，它们的行为有所不同，重要的是要知道它们之间的区别。

## combineLatest

函数签名如下:

```javascript
Rx.Observable.combineLatest([ source_1, ...  source_n])
```

```javascript
let source1 = Rx.Observable.interval(100)
.map( val => "source1 " + val ).take(5);

let source2 = Rx.Observable.interval(50)
.map( val => "source2 " + val ).take(2);

let stream$ = Rx.Observable.combineLatest(
    source1,
    source2
);

stream$.subscribe(data => console.log(data));

// 发出 source1: 0, source2 : 0 |  source1 : 0, source2 : 1 | source1 : 1, source2 : 1, 等等
```

`combineLatest` 实际上是从每个 `source` 取最新的响应值然后返回有x个元素的数组。每个 `source` 对应一个元素。

如你所见，source2 在发出2个值后就停止了，但仍然可以持续发出最新的值。

### 业务场景

业务场景是当你对每个 source 的最新值感兴趣，而对过往的值不感兴趣，当然你要有一个以上想要组合的 source 。

## concat

函数签名如下：

```javascript
Rx.Observable([ source_1,... sournce_n ])
```

看看下面输出的数据，很容易可以想到数据是何时发出的：

```javascript
let source1 = Rx.Observable.interval(100)
.map( val => "source1 " + val ).take(5);

let source2 = Rx.Observable.interval(50)
.map( val => "source2 " + val ).take(2);


let stream$ = Rx.Observable.concat(
    source1,
    source2
);

stream$.subscribe( data => console.log('Concat ' + data));

// source1 : 0, source1 : 1, source1 : 2, source1 : 3, source1 : 4
// source2 : 0, source2 : 1
```

从结果可以看出，组合后的 observable 接收了第一个 source 的所有值然后先将它们发出，然后再接收 source 2的所有值，所以说 `concat()` 操作符中的 source 顺序很重要。

所以当遇到应该优先考虑某个 source 的情况时，就要使用 `concat` 操作符。

## merge

这个操作符可以将多个流合并成一个。

```javascript
let merged$ = Rx.Observable.merge(
    Rx.Observable.of(1).delay(500),
    Rx.Observable.of(3,2,5)
)

let observer = {
    next : data => console.log(data)
}

merged$.subscribe(observer);
```

要点是这个操作符组合了几个流，并且就像你在上面所看到的一样，任何像 `delay()` 这样的时间操作符都是起作用的。

## zip

```javascript
let stream$ = Rx.Observable.zip(
    Promise.resolve(1),
    Rx.Observable.of(2,3,4),
    Rx.Observable.of(7)
);


stream$.subscribe(observer);
```

我们得到 `1,2,7`

再来看另外一个示例

```javascript
let stream$ = Rx.Observable.zip(
    Rx.Observable.of(1,5),
    Rx.Observable.of(2,3,4),
    Rx.Observable.of(7,9)
);

stream$.subscribe(observer);
```

得到的是`1,2,7`和`5,3,9`，所以它是以列为基础连接值的。它将采用最小的共同标准，在这个案例中是2。`2,3,4`序列中`4`会被忽略。正如你在第一个示例中所看见的，它还可以混用不同的异步概念，比如 Promise 和 Observable，这是因为发生了间隔转换。

### 业务场景

如果你真正关心不同 sources 在同一个位置所发出值的区别，假设所有 sources 的第2个响应值，那么你需要 `zip()` 操作符。
