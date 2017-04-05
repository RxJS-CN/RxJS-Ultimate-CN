#Operators matchematical
## max

```
let stream$ = Rx.Observable.of(5,4,7,-1)
.max();
```

This emits `7`. It's obvious what this operator does, it gives us just one value, the max. There is different ways of calling it though. You can give it a comparer:

```
function comparer(x,y) {
    if( x > y ) {
        return 1;
    } else if( x < y ) {
        return -1;
    } else return 0;
}

let stream$ = Rx.Observable.of(5,4,7,-1)
.max(comparer);
```
In this case we define a `comparer` which runs a sort algorithm under the hood and all we have to do is to help it determine when something is *larger than*, *equal* or *smaller than*. Or with an object the idea is the same:

```
function comparer(x,y) {
    if( x.age > y.age ) {
        return 1;
    } else if( x.age < y.age ) {
        return -1;
    } else return 0;
}

let stream$ = Rx.Observable.of({ name : 'chris', age : 37 }, { name : 'chross', age : 32 })
.max(comparer);
```
Because we tell it in the `comparer` what property to compare we are left with the first entry as result.

## min
Min is pretty much identical to `max()` operator but returns the opposite value, the smallest.

## sum
`sum()` as operator has seized to exist but we can use `reduce()` for that instead like so:
```
let stream$ = Rx.Observable.of(1,2,3,4)
.reduce((accumulated, current) => accumulated + current )
```
This can be applied to objects as well as long as we define what the `reduce()` function should do, like so:
```
let objectStream$ = Rx.Observable.of( { name : 'chris' }, { age : 11 } )
.reduce( (acc,curr) => Object.assign({}, acc,curr ));
``` 
This will concatenate the object parts into an object.
## avg