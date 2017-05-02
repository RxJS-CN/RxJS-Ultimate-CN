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

上面的示例其实并不是真正的热的 Observable，事实上两个订阅者接收到的值都是`0,1,2,3,4`。因为这是一场足球比赛的实况直播，所以这样的结果并不是我们想要的，那么如何来修复呢？

需要两个部件来将冷的 Observable 转变成热的， `publish()` 和 `connect()` 。

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

## Warm observables

There is another type of observables that acts a lot like a hot observable but is in a way lazy. What I mean with this is that they are essentially not emitting any values until a subscriber arrives. Let's compare a hot and a warm observable

**hot observable**

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

Here we can see that the hot observable will loose the first value being emitted as the subscribe arrives late to the party.

Let's contrast this to our warm observable

**warm observable**

```javascript
let obs = Rx.Observable.interval(1000).take(3).publish().refCount();

setTimeout(() => {
    obs.subscribe(data => console.log('sub1', data));
},1000)

setTimeout(() => {
    obs.subscribe(data => console.log('sub2', data));
},2000)
```

The `refCount()` operator ensures this observable becomes warm, i.e no values are emitted until `sub1` subscribes. `sub2` on the other hand arrives late to the party, i.e that subscription receives the value its currently on and not the values from the beginning.

## Naturally hot observables

Generally something is considered hot if the values are emitted straight away without the need for a subscriber to be present. A naturally occuring example of a hot observable is `mousemove`. Most other hot observables are the result of cold observables being turned hot by using `publish()` and `connect()` or by using the `share()` operator.

# Sharing

Sharing means using a useful operator called `share()`. Imagine you have the following normal cold observable case :

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

If you set a breakpoint on `observer.next(1)` you will notice that it's being hit twice, once for every subscriber. This is the behaviour we expect from a cold observable. Sharing operator is a different way of turning something into a hot observable, in fact it not only turns something hot under the right conditions but it falls back to being a cold observable under certain conditions. So what are these conditions ?

1) **Created as hot Observable** : An Observable has not completed when a new subscription comes and subscribers > 0

2) **Created as Cold Observable** Number of subscribers becomes 0 before a new subscription takes place. I.e a scenario where one or more subscriptions exist for a time but is being unsubscribed before a new one has a chance to happen

3) **Created as Cold Observable** when an Observable completed before a new subscription

Bottom line here is an active Observable producing values still and have at least one preexisting subscriber. We can see that the Observable in case 1) is dormant before a second subscriber happens and it suddenly becomes hot on the second subscriber and thereby starts sharing the data where it is.
