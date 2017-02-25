# Operators time
There are plenty of operators dealing with time in some way such as `delay` `debounce` `throttle` `interval` etc.

This is not an easy topic. There are many areas of application here, either you might want to synchronize responses from APIS or you might want to deal with other types of streams such as events like clicks or keyup in a UI.

## debounce
TODO
## throttle
TODO

## buffer
This operator has the ability to record x number of emitted values before it outputs its values, this one comes with one or two input parameters.

```
.buffer( whenToReleaseValuesStartObservable )

or

.buffer( whenToReleaseValuesStartObservable, whenToReleaseValuesEndObservable )

```

So what does this mean?
It means given we have for example a click of streams we can cut it into nice little pieces where every piece is equally long. Using the first version with one parameter we can give it a time argument, let's say 500 ms. So something emits values for 500ms then the values are emitted and another Observable is started, and the old one is abandoned. It'a much like using a stopwatch and record for 500 ms at a time. Example :

```
let scissor$ = Rx.Observable.interval(500)

let emitter$ = Rx.Observable.interval(100).take(10) // output 10 values in total
.buffer( scissor$ )

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


