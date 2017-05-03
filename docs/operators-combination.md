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

The result however is that the resulting observable takes all the values from the first source and emits those first then it takes all the values from source 2, so order in which the source go into `concat()` operator matters.

So if you have a case where a source somehow should be prioritized then this is the operator for you.

## merge

This operator enables you two merge several streams into one.

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

Point with is operator is to combine several streams and as you can see above any time operators such as `delay()` is respected.

## zip

```javascript
let stream$ = Rx.Observable.zip(
    Promise.resolve(1),
    Rx.Observable.of(2,3,4),
    Rx.Observable.of(7)
);


stream$.subscribe(observer);
```

Gives us `1,2,7`

Let's look at another example

```javascript
let stream$ = Rx.Observable.zip(
    Rx.Observable.of(1,5),
    Rx.Observable.of(2,3,4),
    Rx.Observable.of(7,9)
);

stream$.subscribe(observer);
```

Gives us `1,2,7` and `5,3,9` so it joins values on column basis. It will act on the least common denominator which in this case is 2. The `4` is ignored in the `2,3,4` sequence. As you can see from the first example it's also possible to mix different async concepts such as Promises with Observables because interval conversion happens.

### Business case

If you really care about what different sources emitted at a certain position. Let's say the 2nd response from all your sources then `zip()` is your operator.
