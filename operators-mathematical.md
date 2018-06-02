#Operators matchematical
## max

```
import { of } from 'rxjs';
import { max } from 'rxjs/operators';

let stream$ = of(5,4,7,-1).pipe(
  max()
)
```

This emits `7`. It's obvious what this operator does, it gives us just one value, the max. There is different ways of calling it though. You can give it a comparer:

```
import { of } from 'rxjs';

function comparer(x,y) {
    if( x > y ) {
        return 1;
    } else if( x < y ) {
        return -1;
    } else return 0;
}

let stream$ = of(5,4,7,-1).pipe(
  max(comparer)
);
```
In this case we define a `comparer` which runs a sort algorithm under the hood and all we have to do is to help it determine when something is *larger than*, *equal* or *smaller than*. Or with an object the idea is the same:

```
import { of } from 'rxjs';
import { max } from 'rxjs/operators'

function comparer(x,y) {
  if( x.age > y.age ) {
    return 1;
  } else if( x.age < y.age ) {
    return -1;
  } else return 0;
}

let stream$ = of(
  { name : 'chris', age : 37 }, 
  { name : 'chross', age : 32 })
.pipe(
  max(comparer)
);
```
Because we tell it in the `comparer` what property to compare we are left with the first entry as result.

## min
Min is pretty much identical to `max()` operator but returns the opposite value, the smallest.

## sum
`sum()` as operator has seized to exist but we can use `reduce()` for that instead like so:
```
import { of } from 'rxjs';
import { reduce } from 'rxjs/operators';

let stream$ = of(1,2,3,4).pipe(
  reduce((accumulated, current) => accumulated + current )
)
```
This can be applied to objects as well as long as we define what the `reduce()` function should do, like so:
```
import { of } from 'rxjs';
import { reduce } from 'rxjs/operators';

let objectStream$ = of(
  { name : 'chris' }, 
  { age : 11 } 
).pipe(
  reduce(
    (acc,curr) => Object.assign({}, acc,curr )
  )
);
``` 
This will concatenate the object parts into an object.
## average
The `average()` operator isn't there anymore in Rxjs5 but you can still achieve the same thing with a `reduce()`

```
import { of } from 'rxjs';
import { map } from 'rxjs/operators';

let stream$ = of( 3, 6 ,9 ).pipe(
  map( x => { return { sum : x, counter : 1 } }),
  reduce( (acc,curr) => {
   return Object.assign(
     {}, 
     acc, 
     { sum : acc.sum + curr.sum ,counter : acc.counter + 1  }
   ),
   map( x => x.sum / x.counter )
 
});
```
I admit it, this one hurted my head a little, once you crack the initial `map()` call the `reduce()` is pretty simple, and `Object.assign()` is a nice companion as usual.
