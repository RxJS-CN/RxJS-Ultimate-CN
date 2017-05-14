# Subject (主体)

Subject 有着双重特性，它同时拥有 [Observer](observer.md) 和 [Observable](observable-anatomy.md) 的行为。因此，以下是可能的：

发出值

```javascript
subject.next( 1 )
subject.next( 2 )
```

订阅值

```javascript
const subscription = subject.subscribe( (value) => console.log(value) )
```

总结以下，它可以进行以下操作：

```javascript
next([value])
error([error message])
complete()
subscribe()
unsubscribe()
```

## 作为代理

`Subject` 可以作为代理，也就是从另一个流接收值，而 `Subject` 的订阅者可以监听另外的这个流。

```javascript
let source$ = Rx.Observable.interval(500).take(3);
const proxySubject = new Rx.Subject();
let subscriber = source$.subscribe( proxySubject );

proxySubject.subscribe( (value) => console.log('proxy subscriber', value ) );

proxySubject.next( 3 );
```

所以本质上 `subject` 监听了 `source$`

但是它还可以增加自己的贡献

```javascript
proxySubject.next( 3 )  // 发出3，然后是0 1 2 ( 异步的 )
```

**陷阱** - 任何在订阅创建之前执行的 `next()` 就会丢失。下面会有其他类型的 Subject 可以解决这个问题。

### 业务场景

那么这有什么有趣的呢？当数据到达时，它可以监听一些数据源，同时还能够发出自己的数据，并且都能到达同一个订阅者。以总线方式在组件之间进行通信的能力是我能想到的最显而易见的用例。组件1可以通过 `next()` 来放置它的值，组件2可以订阅，反之亦然，组件2可以发出值，组件1可以订阅。

```javascript
sharedService.getDispatcher = function(){
   return subject;
}

sharedService.dispatch = function(value){
  subject.next(value)
}
```

## ReplaySubject

原型:

```javascript
new Rx.ReplaySubject([bufferSize], [windowSize], [scheduler])
```

示例:

```javascript
let replaySubject = new Rx.ReplaySubject( 2 );

replaySubject.next( 0 );
replaySubject.next( 1 );
replaySubject.next( 2 );

//  1, 2
let replaySubscription = replaySubject.subscribe((value) => {
    console.log('replay subscription', value);
});
```

Wow, what happened here, what happened to the first number? So a `.next()` that happens before the subscription is created, is normally lost. But in the case of a `ReplaySubject` we have a chance to save emitted values in the cache. Upon creation the cache has been decided to save two values.

Let's illustrate how this works:

```javascript
replaySubject.next( 3 )
let secondSubscriber( (value) => console.log(value) ) // 2,3
```

**GOTCHA** It matters both when the `.next()` operation happens, the size of the cache as well as when your subscription is created.

In the example above it was demonstrated how to use the constructor using `bufferSize` argument in the constructor. However there also exist a `windowSize` argument where you can specify how long the values should remain in the cache. Set it to `null` and it remains in the cache indefinite.

### Business case

It's quite easy to imagine the business case here. You fetch some data and want the app to remember what was fetched latest, and what you fetched might only be relevant for a certain time and when enough time has passed you clear the cache.

## AsyncSubject

```javascript
let asyncSubject = new Rx.AsyncSubject();
asyncSubject.subscribe(
    (value) => console.log('async subject', value),
    (error) => console.error('async error', error),
    () => console.log('async completed')
);

asyncSubject.next( 1 );
asyncSubject.next( 2 );
```

Looking at this we expect 1,2 to be emitted right? WRONG. Nothing will be emitted unless `complete()` happen

```javascript
asyncSubject.next( 3 )
asyncSubject.complete()

// emit 3
```

`complete()` needs to happen regardless of the finishing operation before it succeeds or fails so

```javascript
asyncSubject( 3 )
asyncSubject.error('err')
asyncSubject.complete()

// will emit 'err' as the last action
```

### Business case

When you care about preserving the last state just before the stream ends, be it a value or an error. So NOT last emitted state generally but last _before closing time_. With state I mean value or error.

## BehaviourSubject

This Subject emits, the initial value, the values emitted generally and you can check what it emitted last.

methods:

```
next()
complete()
constructor([start value])
getValue()
```

```javascript
let behaviorSubject = new Rx.BehaviorSubject(42);

behaviorSubject.subscribe((value) => console.log('behaviour subject',value) );
console.log('Behaviour current value',behaviorSubject.getValue());
behaviorSubject.next(1);
console.log('Behaviour current value',behaviorSubject.getValue());
behaviorSubject.next(2);
console.log('Behaviour current value',behaviorSubject.getValue());
behaviorSubject.next(3);
console.log('Behaviour current value',behaviorSubject.getValue());

// emits 42
// current value 42
// emits 1
// current value 1
// emits 2
// current value 2
// emits 3
// current value 3
```

### Business case

This is quite similar to `ReplaySubject`. There is a difference though, we can utilize a default / start value that we can show initially if it takes some time before the first values starts to arrive. We can inspect the latest emitted value and of course listen to everything that has been emitted. So think of `ReplaySubject` as more _long term memory_ and `BehaviourSubject` as short term memory with default behaviour.
