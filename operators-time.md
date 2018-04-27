# Operators time
This is not an easy topic. There are many areas of application here, either you might want to synchronize responses from APIS or you might want to deal with other types of streams such as events like clicks or keyup in a UI.

There are plenty of operators dealing with time in some way such as `delay` `debounce` `throttle` `interval` etc.

This is not an easy topic. There are many areas of application here, either you might want to synchronize responses from APIS or you might want to deal with other types of streams such as events like clicks or keyup in a UI.


## interval
This operator is used to construct an Observable and essentially what it does is to pump values at regular interval, signature:

```
import { interval } from 'rxjs';

interval([ms])
```

Example usage:

```
import { interval } from 'rxjs';

interval(100)

// generates forever
```

Because this one will generate values forever you tend to want to combine it with the `take()` operator that limits the amount of values to generate before calling it quits so that would look like :

```
import { interval } from 'rxjs';

interval(1000).take(3)

// generates 1,2,3
```  

## timer
Timer is an interesting one as it can act in several ways depending on how you call it. It's signature is

```
import { timer } from 'rxjs';

timer([initial delay],[thereafter])
```
However only the initial args is mandatory so depending on the number of args used these are the different types that exist because of it.

**one-off**
```
import { timer } from 'rxjs';

let stream$ = timer(1000);

stream$.subscribe(data => console.log(data));

// generates 0 after 1 sec
```

This becomes a one-ff as we don't define when the next value should happen.

**with 2nd arg specified**
```
import { timer } from 'rxjs';
import { take } from 'rxjs/operators';

let moreThanOne$ = timer(2000, 500).pipe(
  take(3)
);

moreThanOne$.subscribe(data => console.log('timer with args', data));

// generate 0 after 2 sec and thereafter 1 after 500ms and 2 after additional 500ms
```
So this one is more flexible and keeps emitting values according to 2nd argument.


## delay
`delay()` is an operator that delays every value being emitted
Quite simply it works like this :
```
import { interval } from 'rxjs';
import { take, delay } from 'rxjs/operators';

var start = new Date();
let stream$ = interval(500).pipe(
  take(3)
);

stream$.pipe(
  delay(300)
)
.subscribe((x) => {
  console.log('val',x);
  console.log( new Date() - start );
})

//0 800ms, 1 1300ms,2 1800ms
```


### Business case
Delay can be used in a multitude of places but one such good case is when handling errors especially if we are dealing with `shaky connections` and want it to retry the whole stream after x miliseconds:

Read more in chapter [Error handling](/error-handling.md)

## sample
I usually think of this scenario as *talk to the hand*.
What I mean by that is that events are only fired at specific points 

### Business case
So the ability to ignore events for x miliseconds is pretty useful. Imagine a save button being repeatedly pushed. Wouldn't it be nice to only act after x miliseconds and ignore the other pushes ?

```
import { fromEvent } from 'rxjs';
import { sampleTime } from 'rxjs/operators';

const btn = document.getElementById('btnIgnore');
var start = new Date();

const input$ = fromEvent(btn, 'click').pipe(
  sampleTime(2000)
);

input$.subscribe(val => {
  console.log(val, new Date() - start);
});
```
The code above does just that.


## debounceTime
So `debounceTime()` is an operator that tells you: I will not emit the data all the time but at certain intervals.

### Business case
Debounce is a known concept especially when you type keys on a keyboard. It's a way of saying we don't care about every keyup but once you stop typing for a while we should care. That, is how you would normally start an auto complete. Say your user hasn't typed for x miliseconds that probably means we should be doing an ajax call and retrieve a result.

```
import { fromEvent } from 'rxjs';
import { map, debounceTime } from 'rxjs/operators';

const input = document.getElementById('input');

const example = fromEvent(input, 'keyup').pipe(
  map(i => i.currentTarget.value)
);

//wait 0.5s, between keyups, throw away all other values
const debouncedInput = example.pipe(
  debounceTime(500)
);

const subscribe = debouncedInput.subscribe(val => {
  console.log(`Debounced Input: ${val}`);
});
```
The following only outputs a value, from our input field, after you stopped typing for 500ms, then it's worth reporting about it, i.e emit a value. 

## throttleTime
TODO

## buffer
This operator has the ability to record x number of emitted values before it outputs its values, this one comes with one or two input parameters.

```
import { buffer } from 'rxjs/operators';



buffer( whenToReleaseValuesStartObservable )

or

buffer( 
  whenToReleaseValuesStartObservable, 
  whenToReleaseValuesEndObservable 
)

```

So what does this mean?
It means given we have for example a click of streams we can cut it into nice little pieces where every piece is equally long. Using the first version with one parameter we can give it a time argument, let's say 500 ms. So something emits values for 500ms then the values are emitted and another Observable is started, and the old one is abandoned. It's much like using a stopwatch and record for 500 ms at a time. Example :

```
import { interval } from 'rxjs';
import { take, buffer } from 'rxjs/operators';

let scissor$ = interval(500);

let emitter$ = interval(100).pipe(
  take(10),
  .buffer( scissor$ )
) // output 10 values in total


// [0,1,2,3,4] 500ms [5,6,7,8,9]
```

Marble diagram

```
--- c --- c - c --- >
-------| ------- |- >
Resulting stream is :
------ r ------- r r  -- > 
```

### Business case
So whats the business case for this one?
`double click`, it's obviously easy to react on a `single click` but what if you only want to perform an action on a `double click` or `triple click`, how would you write code to handle that? You would probably start with something looking like this :

```

$('#btn').bind('click', function(){
  if(!start) { start = timer.start(); }
  timePassedSinceLastClickInMs = now - start;
  if(timePassedSinceLastClickInMs < 250) {
     console.log('double click');
       
  } else {
     console.log('single click')
  }
  
  start = timer.start();  
})
```
Look at the above as an attempt at pseudo code. The point is that you need to keep track of a bunch of variables of how much time has passed between clicks. This is not nice looking code, lacks elegance

#### Model in Rxjs
By now we know Rxjs is all about streams and modeling values over time.
Clicks are no different, they happen over time.
```
---- c ---- c ----- c ----- >
```
We however care about the clicks when they appear close together in time, i.e as double or triple clicks like so :

 ```
 --- c - c ------ c -- c -- c ----- c 
 ``` 
 From the above stream you should be able to deduce that a `double click`, one `triple click` and one `single click` happened.

So let's say I do, then what?
You want the stream to group itself nicely so it tells us about this, i.e it needs to emit these clicks as a group. `filter()` as an operator lets us do just that. If we define let's say 300ms is a long enough time to collect events on, we can slice up our time from 0 to forever in chunks of 300 ms with the following code:  

```
let clicks$ = Rx.Observable.fromEvent(document.getElementById('btn'), 'click');

let scissor$ = Rx.Observable.interval(300);

clicks$.buffer( scissor$ )
      //.filter( (clicks) => clicks.length >=2 )
      .subscribe((value) => {
          if(value.length === 1) {
            console.log('single click')
          }
          else if(value.length === 2) {
            console.log('double click')
          }
          else if(value.length === 3) {
            console.log('triple click')
          }
          
      });
```

Read the code in the following way, the buffer stream, `clicks$` will emit its values every 300ms, 300 ms is decided by `scissor$` stream. So the `scissor$` stream is the scissor, if you will, that cuts up our click stream and voila we have an elegant `double click` approach. As you can see the above code captures all types of clicks but by uncommenting the `filter()` operation we get only `double clicks` and `triple clicks`. 

`filter()` operator can be used for other purposes as well like recording what happened in a UI over time and replay it for the user, only your imagination limits what it can be used for.


