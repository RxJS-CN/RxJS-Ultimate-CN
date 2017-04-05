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

## concat
The signature is :

```
Rx.Observable([ source_1,... sournce_n ])
```

Looking at the following data, it's easy to think that it should care when data is emitted:

```
let source1 = Rx.Observable.interval(100)
.map( val => "source1 " + val ).take(5);

let source2 = Rx.Observable.interval(50)
.map( val => "source2 " + val ).take(2);


let stream$ = Rx.Observable.concat(
    source1, 
    source2
);

stream$.subscribe( data => console.log('Concat ' + data));

// source1 : 0, source1 : 1, source1 : 2, source1 : 3, source1 : 4
// source2 : 0, source2 : 1 
```
The result however is that the resulting observable takes all the values from the first source and emits those first then it takes all the values from source 2, so order in which the source go into `concat()` operator matters.

So if you have a case where a source somehow should be prioritized then this is the operator for you.

## merge
This operator enables you two merge several streams into one.
```
let merged$ = Rx.Observable.merge(
    Rx.Observable.of(1).delay(500),
    Rx.Observable.of(3,2,5)
)

let observer = {
    next : data => console.log(data)
}

merged$.subscribe(observer);
```
Point with is operator is to combine several streams and as you can see above any time operators such as `delay()` is respected.

## zip

```
let stream$ = Rx.Observable.zip(
    Promise.resolve(1),
    Rx.Observable.of(2,3,4),
    Rx.Observable.of(7)
);


stream$.subscribe(observer); 
```
Gives us `1,2,7`

Let's look at another example
```
let stream$ = Rx.Observable.zip(
    Rx.Observable.of(1,5),
    Rx.Observable.of(2,3,4),
    Rx.Observable.of(7,9)
);

stream$.subscribe(observer);
```
Gives us `1,2,7` and `5,3,9` so it joins values on column basis. It will act on the least common denominator which in this case is 2. The `4` is ignored in the `2,3,4` sequence.


