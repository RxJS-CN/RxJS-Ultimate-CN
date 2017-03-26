#Operators combination
There are many operators out there that allows you to combine the values from 2 or more source, they act a bit differently though and its important to know the difference.

## combineLatest

The signature on this one is:
```
Rx.Observable.combineLatest([ source_1, ...  source_n])
```

```
let source1 = Rx.Observable.interval(100)
.map( val => "source1 " + val ).take(5);

let source2 = Rx.Observable.interval(50)
.map( val => "source2 " + val ).take(2);

let stream$ = Rx.Observable.combineLatest(
    source1,
    source2
);

stream$.subscribe(data => console.log(data));

// emits source1: 0, source2 : 0 |  source1 : 0, source2 : 1 | source1 : 1, source2 : 1, etc
```

What this does is to essentially take the latest response from each `source` and return it as an array of x number of elements. One element per source.

As you can see source2 stops emitting after 2 values but is able to keep sending the latest emitted. 

### Business case
The business case is when you are interested in the very latest from each source and past values is of less interest, and of course you have more than one source that you want to combine.


