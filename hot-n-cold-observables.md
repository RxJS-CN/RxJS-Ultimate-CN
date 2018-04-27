# Hot n Cold Observables

There are hot and cold observables. Let's talk about what a cold observable is. In a cold observable two subscribers get their own copies of values like so:

```
// cold observable example
import { of } from 'rxjs';

let stream$ = of(1,2,3);
//subscriber 1: 1,2,3
stream.subscribe(
   data => console.log(data),
   err => console.error(err),
   () => console.log('completed')
)

//subscriber 2: 1,2,3
stream.subscribe(
   data => console.log(data),
   err => console.error(err),
   () => console.log('completed')
)
```

In a hot observable a subscriber receives values when it starts to subscribe, it is however more like a live streaming in football, if you start subscribing 5 minutes in the game, you will have missed the first 5 minutes of action and you start receiving data from that moment on:

```
import { interval } from 'rxjs';
import { take } from 'rxjs/operators';

let liveStreaming$ = interval(1000).pipe(
  take(5)
);

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

## From cold to hot - Katy Perry mode

In the example above it isn't really hot, as a matter of fact both subscribers of the values will each receive `0,1,2,3,4`. As this is the live streaming of a football game it doesn't really act like we want it to, so how to fix it?

Two components are needed to make something go from cold to hot. `publish()` and `connect()`.

```
import { interval } from 'rxjs';
import { take, publish } from 'rxjs/operators';

let publisher$ = 
interval(1000).pipe(
  take(5),
  publish()
);


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

In this case we see that the output for the first stream that starts to subscribe straight away is `0,1,2,3,4` whereas the second stream is emitting `3,4`. It's clear it matters when the subscription happens.

## Warm observables

There is another type of observables that acts a lot like a hot observable but is in a way _lazy_. What I mean with this is that they are essentially not emitting any values until a subscriber arrives. Let's compare a hot and a warm observable

**hot observable**

```
import { interval } from 'rxjs';
import { take, publish } from 'rxjs/operators';

let stream$ = 
interval(1000).pipe(
  take(4),
  publish()
);

stream$.connect();

setTimeout(() => {
  stream$.subscribe(data => console.log(data))
}, 2000);
```

Here we can see that the hot observable will loose the first value being emitted as the subscribe arrives late to the party.

Let's contrast this to our warm observable

**warm observable**

```
import { interval } from 'rxjs';
import { take, publish, refCount } from 'rxjs/operators';

let obs = interval(1000).pipe(
  take(3),
  publish(),
  refCount()
);

setTimeout(() => {
  obs.subscribe(data => console.log('sub1', data));
},1100)

setTimeout(() => {
  obs.subscribe(data => console.log('sub2', data));
},2100)
```

The `refCount()` operator ensures this observable becomes warm, i.e no values are emitted until `sub1` subscribes. `sub2` on the other hand arrives late to the party, i.e that subscription receives the value its currently on and not the values from the beginning.

So an output from this is

```
sub1 : 0
sub1 : 1
sub2 : 1
sub1 : 2
sub2 : 2
```

This shows the following, first subscriber starts from 0. Had it been hot it would have started at a higher number, i/e it would have been late to the party. When the second subscriber arrives it doesn't get 0 but rather 1 as the first number showing it has indeed become hot.

## Naturally hot observables

Generally something is considered hot if the values are emitted straight away without the need for a subscriber to be present. A naturally occuring example of a hot observable is `mousemove`. Most other hot observables are the result of cold observables being turned hot by using `publish()` and `connect()` or by using the `share()` operator.

# Sharing

Sharing means using a useful operator called `share()`. Imagine you have the following normal cold observable case :

```
import { Observable } from 'rxjs';

let stream$ = Observable.create((observer) => {
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

If you set a breakpoint on `observer.next(1)` you will notice that it's being hit twice, once for every subscriber. This is the behaviour we expect from a cold observable. Sharing operator is a different way of turning something into  a hot observable, in fact it not only turns something hot under the right conditions but it falls back to being a cold observable under certain conditions. So what are these conditions ?

1\) **Created as hot Observable** : An Observable has not completed when a new subscription comes and subscribers &gt; 0

2\)   **Created as Cold Observable** Number of subscribers becomes 0 before a new subscription takes place. I.e a scenario where one or more subscriptions exist for a time but is being unsubscribed before a new one has a chance to happen

3\) **Created as Cold Observable** when an Observable completed before a new subscription

Bottom line here is an _active_ Observable producing values still and have at least one preexisting subscriber. We can see that the Observable in case 1\) is dormant before a second subscriber happens and it suddenly becomes hot on the second subscriber and thereby starts sharing the data where it is.

