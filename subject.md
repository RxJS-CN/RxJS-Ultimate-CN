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
let source$ = Rx.Observable.interval( 500 ).take(3);
const proxySubject = new Subject();
let subscriber = source$.subscribe( proxySubject );

subscriber.subscribe( (value) => console.log( value )  ) // 0 1 2
```

So essentially subject `listens` to `source$`

But it can also add its own contribution

```
proxySubject.next( 3 )  // emits 3 after 0 1 2

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
let replaySubject = new Rx.ReplaySubject(<cache size>);
let subscriber = replaySubject.subscribe((value) => console.log(value)) //

replaySubject.next( 1 )
replaySubject.next( 2 )
replaySubject.next( 3 )

```

#### Business case
### AsyncSubject
#### Business case
### BehaviourSubject
#### Business case




