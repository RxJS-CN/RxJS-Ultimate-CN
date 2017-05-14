# Operators Grouping

## buffer

The signature of `buffer()` operator is :

```javascript
buffer([breakObservable])
```

Buffer itself means we wait with emitting any values until the `breakObservable` happens. An example of that is the following:

```javascript
let breakWhen$ = Rx.Observable.timer(1000);

let stream$ = Rx.Observable.interval(200)
.buffer( breakWhen$ );

stream$.subscribe((data) => console.log( 'values',data ));
```

In this case the values 0,1,2,3 is emitted all at once.

### Business case

**Auto complete** The most obvious case when dealing with the `buffer()` operator is an `auto complete`. But how does `auto complete` work? Let's look at it in steps

  * user enter keys
  * search is made base on those keystrokes. The important thing though is that the search itself is carried out as you are typing, either it's carried out because you typed x number of characters or the more common approach is to let you finish typing and do the search, you could be editing as you type. So let's take our first step into such a solution:

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'keyup' )

let breakWhen$ = Rx.Observable.timer(1000);
let debounceBreak$ = input$.debounceTime( 2000 );

let stream$ = input$
.map( ev => ev.key )
.buffer( debounceBreak$ );

stream$.subscribe((data) => console.log( 'values',data ));
```

We capture `keyup` events. We also use a `debounce()` operator that essentially says; I will emit values once you stopped typing for x miliseconds. This solution is just a first step on the way however as it is reporting the exact keys being typed. A better solution would be to capture the input element's actual content and also to perform an ajax call, so let's look at a more refined solution:

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'keyup' )

let breakWhen$ = Rx.Observable.timer(1000);
let debounceBreak$ = input$.debounceTime( 2000 );

let stream$ = input$
.map( ev => {
    return ev.key })
.buffer( debounceBreak$ )
.switchMap((allTypedKeys) => {
    // do ajax
    console.log('Everything that happened during 2 sec', allTypedKeys)
    return Rx.Observable.of('ajax based on ' + input.value);
});

stream$.subscribe((data) => console.log( 'values',data ));
```

Let's call this one `auto complete on steroids`. The reason for the name is that we save every single interaction the user does before finally deciding on the final input that should become an Ajax call. So a result from the above could look like the following:

```javascript
// from switchMap
Everything that happened during 2 sec ["a", "a", "a", "Backspace", "Backspace", "Backspace", "Backspace", "b", "b", "Backspace", "Backspace", "Backspace", "f", "g", "h", "f", "h", "g"]

// in the subscribe(fnValue)
app-buffer.js:31 values ajax based on fghfgh
```

As you can see we could potentially store a whole lot more about a user than just the fact that they made an auto complete search, we can store how they type and that may or may not be interesting..

**Double click** In the example above I've showed how it could be intersting to capture groups of keys but another group of UI events of possible interests are mouse clicks, namely for capturing single, double or triple clicks. This is quite inelegant code to write if not in Rxjs but with it, it's a breeze:

```javascript
let btn = document.getElementById('btn2');
let btn$  = Rx.Observable.fromEvent( btn, 'click' )

let debounceMouseBreak$ = btn$.debounceTime( 300 );

let btnBuffered$ = btn$
.buffer( debounceMouseBreak$ )
.map( array => array.length )
.filter( count => count >= 2 )
;

btnBuffered$.subscribe((data) => console.log( 'values',data ));
```

Thanks to the `debounce()` operator we are able to express wait for 300ms before emitting anything. This is quite few lines and it's easy for us to decide what our filter should look like.

## bufferTime

The signature of `bufferTime()` is

```javascript
bufferTime([ms])
```

The idea is to record everything that happens during that time slice and output all the values. Below is an example of recording all activities on an input in 1 second time slices.

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'input' )
.bufferTime(1000);

input$.subscribe((data) => console.log('all inputs in 1 sec', data));
```

In this case you will get an output looking like:

```javascript
all inputs in 1 sec [ Event, Event... ]
```

Not so usable maybe so we probably need to make it nice with a `map()` to see what was actually typed, like so:

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'keyup' )
.map( ev => ev.key)
.bufferTime(1000);

input$.subscribe((data) => console.log('all inputs in 1 sec', data));
```

Also note I changed event to `keyup`. Now we are able to see all `keyup` events that happened for a sec.

### 业务场景

The example above could be quite usable if you want to record what another user on the site is doing and want to replay all the interactions they ever did or if they started to type and you want to send this info over a socket. The last is something of a standard functionality nowadays that you see a person typing on the other end. So there are definitely use cases for this.

## groupBy

TODO
