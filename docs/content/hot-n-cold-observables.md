# 热&冷的 Observables

Observable 有冷热两种类型。我们先来看看什么是冷的 observable 。如果是冷的 observable 的话，那么两个订阅者得到值是两份完全相同的副本，示例如下：

```javascript
// 冷的 observable 示例
let stream$ = Rx.Observable.of(1,2,3);
//订阅者 1: 1,2,3
stream.subscribe(
   data => console.log(data),
   err => console.error(err),
   () => console.log('completed')
)

//订阅者 2: 1,2,3
stream.subscribe(
   data => console.log(data),
   err => console.error(err),
   () => console.log('completed')
)
```

如果是热的 observable 的话，订阅者只能收到当它开始订阅后的值，这很像是足球比赛的实况直播，如果你在开场5分钟后才开始观看，你会错失开场前5分钟的一切，从观看的这一刻起你才开始接收数据：

```javascript
let liveStreaming$ = Rx.Observable.interval(1000).take(5);

liveStreaming$.subscribe(
  data => console.log('subscriber from first minute')
  err => console.log(err),
  () => console.log('completed')
)

setTimeout(() => {
   liveStreaming$.subscribe(
  data => console.log('subscriber from 2nd minute')
  err => console.log(err),
  () => console.log('completed')
)
},2000)
```

## 由冷及热 - 凯蒂·佩里模式

上面的示例其实并不是真正的热的 observable，事实上两个订阅者接收到的值都是`0,1,2,3,4`。因为这是一场足球比赛的实况直播，所以这样的结果并不是我们想要的，那么如何来修复呢？

需要两个部件来将冷的 observable 转变成热的， `publish()` 和 `connect()` 。

```javascript
let publisher$ = Rx.Observable
.interval(1000)
.take(5)
.publish();


publisher$.subscribe(
  data => console.log('subscriber from first minute',data),
  err => console.log(err),
  () => console.log('completed')
)

setTimeout(() => {
    publisher$.subscribe(
        data => console.log('subscriber from 2nd minute', data),
        err => console.log(err),
        () => console.log('completed')
    )
}, 3000)


publisher$.connect();
```

在这个案例中，我们看到第一个订阅者输出的是`0,1,2,3,4`，而第二个输出的是`3,4`。很明显订阅的时间点是很重要的。

## 暖的 Observables

这是 observalbes 的另外一种类型，它的表现很像热的 observable ，但它在某种程度上是惰性的。我想表达的是从本质上来说，在有订阅发生之前它们不会发出任何值。让我们来比较一下热的和暖的 observable

**热的 observable**

```javascript
let stream$ = Rx.Observable
.interval(1000)
.take(4)
.publish();

stream$.connect();

setTimeout(() => {
  stream$.subscribe(data => console.log(data))
}, 2000);
```

这里我们可以看到热的 observable 会丢失第一个发出的值，因为订阅是延迟发生的。

和暖的 observable 进行下对比

**暖的 observable**

```javascript
let obs = Rx.Observable.interval(1000).take(3).publish().refCount();

setTimeout(() => {
    obs.subscribe(data => console.log('sub1', data));
},1000)

setTimeout(() => {
    obs.subscribe(data => console.log('sub2', data));
},2000)
```

`refCount()` 操作符确保 observable 变成暖的，也就是不会发出值直到 `sub1` 订阅了流。另一方面 `sub2` 是后加入的，也就是说订阅接收的是当前的值，而无法接收订阅之前的值。

## 天生的热 observables

通常来说，如果 observable 的值被立即发出而不需要订阅者的话，那么就认为它是热的，一个最常见的例子就是 `mousemove` 。其它大多数热的 observables 都是通过使用 `publish()` 和 `connect()` ，或者使用 `share()` 操作符将冷的 observables 转变成热的结果。

# 共享

共享意味着要使用一个十分有用，叫做 `share()` 的操作符。想象一下你有这样一个普通的冷 observable：

```javascript
let stream$ = Rx.Observable.create((observer) => {
    observer.next( 1 );
    observer.next( 2 );
    observer.next( 3 );
    observer.complete();
}).share()

stream$.subscribe(
    (data) => console.log('subscriber 1', data),
    err => console.error(err),
    () => console.log('completed')
);
stream$.subscribe(
    (data) => console.log('subscriber 2', data),
    err => console.error(err),
    () => console.log('completed')
);
```

如果在 `observer.next(1)` 打个断点，你会注意到它执行了两次，每个订阅者一次。这个行为是我们对冷的 observable 的期望。共享操作符用了一种不同的方式将其转换成热的 observable，事实上，它不仅在正确的条件下转变成热的 observable，而且在某些条件下可以回退成冷的 observable 。那么这些条件是？

1) **创建热的 Observable**： 当有新的订阅时 Observable 还未完成并且订阅者数量大于0

2) **创建冷的 Observable** 在新的订阅之前订阅者的数量已经变成了0，也就是说，一个或多个订阅存在过一段时间，但是在新的订阅发生前已经取消了订阅。

3) **创建冷的 Observable** 当新的订阅发生之前 Observable 已经完成

结果就是一个**活动的** Observable 要继续产生值至少要有一个存在的订阅者。我们可以看到情况1)中的 Observable 在第有两个订阅者之前是休眠的，当订阅发生时它会立即转变成热的从而开始共享数据。
