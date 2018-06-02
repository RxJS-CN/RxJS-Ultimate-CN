#Observable in an Observable

Quite often you come to a point where you start with one type of Observable and you want it to turn into something else. 

## Example

```
import { of } from 'rxjs';
import { ajax } from 'rxjs/ajax';
import { flatMap, map } from 'rxjs/operators';

let stream$ = of(1,2,3)
.pipe(
  flatMap((val) => {
    return of(val).pipe(
        ajax({ url : url + })).pipe(
          map((e) => e.response)
        )
    ); 
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
import { of } from 'rxjs';
import { ajax } from 'rxjs/ajax';
import { map } from 'rxjs/operators';

let stream$ = of(1,2,3).pipe(
  map((val) => {
    return of(val)
      .pipe(
        ajax({ url : url + }) )
        .pipe(
          map((e) => e.response ) 
        )
      )
  }
);

```

is that it would not give the result we want instead the result would be:

```
// Observable, Observable, Observable
```
because we have created a list of observables, so three different streams. The `flatMap()` operator however is able to flatten these three streams into one stream called a `metastream`. There is however another interesting operator that we should be using when dealing with ajax generally and it's called `switchMap()`. Read more about it here  [Cascading calls](/cascading-calls.md)


