#Subject 
A Subject is a double nature. It has both the behaviour from an [Observer](/observer.md) and an [Observable](/observable-anatomy.md). Thus the following is possible:

Emitting values

```
subject.next( 1 )
subject.next( 2 ) 
```

Subscribing to values

```
const subscription = subject.subscribe( (value) => console.log(value) )
```
The sum it up the following operations exist on it:

```
next(<value>)
error(<error message>)
complete()
subscribe()
unsubscribe()
```

## Acting as a proxy
A `Subject` can act as a proxy, i.e receive values from another stream that the subscriber of the `Subject` can listen to.

```
let source$ = Rx.Observable.interval(500).take(3);
const proxySubject = new Rx.Subject();
let subscriber = source$.subscribe( proxySubject );

proxySubject.subscribe( (value) => console.log('proxy subscriber', value ) );

proxySubject.next( 3 );
```

So essentially subject `listens` to `source$`

But it can also add its own contribution

```
proxySubject.next( 3 )  // emits 3 and then 0 1 2 ( async )

```

## Subject sub types
There are different kind of Subject, all with their own use cases.
### ReplaySubject

prototype:
```
new Rx.ReplaySubject(<cache size>)
```

example:
```
let replaySubject = new Rx.ReplaySubject(2);

replaySubject.next( 1 )
replaySubject.next( 2 )
replaySubject.next( 3 )

let subscriber = replaySubject.subscribe((value) => console.log(value)) // 2 3

```

Wow, what happenend here, what happened to the first number?
So a `.next()` that happens before the subscription is created is normally lost. But in the case of a `ReplaySubject` we have a chance to save emitted values in the cache. Upon creation the cache has been decided to save two values.

Let's illustrate how this works:
```
replaySubject.next( 3 )
let secondSubscriber( (value) => console.log(value) ) // 2,3

```
**GOTCHA**
It matters both when the `.next()` operation happens, the size of the cache as well as when your subscription is created.


#### Business case
### AsyncSubject
#### Business case
### BehaviourSubject
#### Business case




