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
In this case we define a `comparer` which runs a sort algorithm under the hood and all we have to do is to help it determine when something is *larger than*, *equal* or *smaller than*. 

## min
## sum
## avg