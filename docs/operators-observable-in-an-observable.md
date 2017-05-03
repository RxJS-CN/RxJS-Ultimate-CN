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

The reason for us NOT doing it like this with a `.map()` operator

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

is that it would not give the result we want instead the result would be:


```javascript
// Observable, Observable, Observable
```

because we have created a list of observables, so three different streams. The `flatMap()` operator however is able to flatten these three streams into one stream called a `metastream`. There is however another interesting operator that we should be using when dealing with ajax generally and it's called `switchMap()`. Read more about it here [Cascading calls](cascading-calls.md)
