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

Min is pretty much identical to `max()` operator but returns the opposite value, the smallest.

## sum

`sum()` as operator has seized to exist but we can use `reduce()` for that instead like so:

```javascript
let stream$ = Rx.Observable.of(1,2,3,4)
.reduce((accumulated, current) => accumulated + current )
```

This can be applied to objects as well as long as we define what the `reduce()` function should do, like so:

```javascript
let objectStream$ = Rx.Observable.of( { name : 'chris' }, { age : 11 } )
.reduce( (acc,curr) => Object.assign({}, acc,curr ));
```

This will concatenate the object parts into an object.

## average

The `average()` operator isn't there anymore in Rxjs5 but you can still achieve the same thing with a `reduce()`

```javascript
let stream$ = Rx.Observable.of( 3, 6 ,9 )
.map( x => { return { sum : x, counter : 1 } } )
.reduce( (acc,curr) => {
    return Object.assign({}, acc, { sum : acc.sum + curr.sum ,counter : acc.counter + 1  })
})
.map( x => x.sum / x.counter )
```

I admit it, this one hurted my head a little, once you crack the initial `map()` call the `reduce()` is pretty simple, and `Object.assign()` is a nice companion as usual.
