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
```


