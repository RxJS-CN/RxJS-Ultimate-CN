#Observable in an Observable

Quite often you come to a point where you start with one type of Observable and you want it to turn into something else. 

## Example

```
let stream$ = Rx.Observable
.of(1,2,3)
.flatMap((val) => {
  return Rx.Observable
            .of(val)
            .ajax({ url : url + }) )
            .map((e) => e.response ) 
}

stream.subscribe((val) => console.log(val))

// { id : 1, name : 'Darth Vader' }, 
// { id : 2, name : 'Emperor Palpatine' },
// { id : 3, name : 'Luke Skywalker' }

```

So here we have a case of starting with values 1,2,3 and wanting those to lead up to an ajax call each

--1------2-----3------>
--json-- json--json -->

The reason for us NOT doing it like this with a `.map()` operator

```
let stream$ = Rx.Observable
.of(1,2,3)
.map((val) => {
  return Rx.Observable
            .of(val)
            .ajax({ url : url + }) )
            .map((e) => e.response ) 
}

```

is that it would not give the result we want instead the result would be:

```
// Observable, Observable, Observable
```
because we have created a list of observables, so three different streams. The `flatMap()` operator however is able to flatten these three streams into one stream called a `metastream`.


