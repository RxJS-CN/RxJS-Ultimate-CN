# 高阶 Observable

通常你会遇到这种情况，以一种类型的 Observable 为起始，然后你想要将它转变为其它的东西。

## 示例

```javascript
let stream$ = Rx.Observable
.of(1,2,3)
.flatMap((val) => {
  return Rx.Observable
            .of(val)
            .ajax({ url : url })
            .map((e) => e.response )
})

stream.subscribe((val) => console.log(val))

// { id : 1, name : 'Darth Vader' },
// { id : 2, name : 'Emperor Palpatine' },
// { id : 3, name : 'Luke Skywalker' }
```

这里我们以值1,2,3为起始，然后想把每个值来引导一次 ajax 请求

--1------2-----3------> --json-- json--json -->

我们没有像下面这样使用 `.map()` 操作符的理由

```javascript
let stream$ = Rx.Observable
.of(1,2,3)
.map((val) => {
  return Rx.Observable
            .of(val)
            .ajax({ url : url })
            .map((e) => e.response )
})
```

是它给你的结果不是你想要的，而会是下面这样：


```javascript
// Observable, Observable, Observable
```

因为我们创建了一个 observable 列表，即三个不同的流，所以订阅得到是流而不是我们想要的数据。然而 `flatMap()` 操作符可以把这种叫做 `metastream` 的流中流变扁平。还有一个有趣的操作符叫做 `switchMap()`，通常它用来处理 ajax 。想了解更多，请参见[级联调用](cascading-calls.md)
