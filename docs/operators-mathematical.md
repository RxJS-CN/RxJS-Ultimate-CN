# 数学操作符

## max

```javascript
let stream$ = Rx.Observable.of(5,4,7,-1)
.max();
```

发出的值是`7`。这个操作符的功能显而易见，只提供一个最大值。还有不同的方式来调用它，可以传入一个 comparer 函数：

```javascript
function comparer(x,y) {
    if( x > y ) {
        return 1;
    } else if( x < y ) {
        return -1;
    } else return 0;
}

let stream$ = Rx.Observable.of(5,4,7,-1)
.max(comparer);
```

在这个案例中，我们定义了 `comparer` 函数，它会在底层运行排序算法，我们所要做的只是帮助它判断是 **大于**、**等于** 还是 **小于**。还可以使用对象进行比较，概念都是一样的：

```javascript
function comparer(x,y) {
    if( x.age > y.age ) {
        return 1;
    } else if( x.age < y.age ) {
        return -1;
    } else return 0;
}

let stream$ = Rx.Observable.of({ name : 'chris', age : 37 }, { name : 'chross', age : 32 })
.max(comparer);
```

因为我们在 `comparer` 中声明了要比较什么属性，所以第一条数据会被留下作为结果。

## min

`min` 和 `max()` 操作符基本一样，只是返回的是最小值。

## sum

`sum()` 操作符已经不复存在，但是我们可以使用 `reducer()` 来完成同样的功能，像这样：

```javascript
let stream$ = Rx.Observable.of(1,2,3,4)
.reduce((accumulated, current) => accumulated + current )
```

同样也适用于对象，只要我们定义好 `reduce()` 函数应该怎么做，像这样：

```javascript
let objectStream$ = Rx.Observable.of( { name : 'chris' }, { age : 11 } )
.reduce( (acc,curr) => Object.assign({}, acc,curr ));
```

这会把所有对象合并为一个对象。

## average

RxJS 5中取消了 `average()` 操作符，但是仍可以使用 `reduce()` 来完成同样的功能

```javascript
let stream$ = Rx.Observable.of( 3, 6 ,9 )
.map( x => { return { sum : x, counter : 1 } } )
.reduce( (acc,curr) => {
    return Object.assign({}, acc, { sum : acc.sum + curr.sum ,counter : acc.counter + 1  })
})
.map( x => x.sum / x.counter )
```

我承认这个实现有一点绕，一旦你理解了起初调用的 `map()`，那么 `reduce()` 就很好理解了，`Object.assign()` 一如既往的是个好助手。
