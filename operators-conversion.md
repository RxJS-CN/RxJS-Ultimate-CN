# Operators conversion
The whole point with this category is to show how easy it is to create Observables from something so they can play nice with the operators and well whatever construct you come from enables rich composition.

## from

In Rxjs4 there existed a bunch of operators with resembling names such as `fromArray()`, `from()`, `fromPromise()` etc. All these `from()` operators are now just `from()`. Let's look at some examples:

**old fromArray**
```
Rx.Observable.from([2,3,4,5])
```

**old fromPromise **
```
Rx.Observable.from(new Promise(resolve, reject) => {
  // do async work
  resolve( data )
})
```

## of
The `of` operator takes x number of arguments so you can call it with one arguments as well as 10 arguments like so:

```
Rx.Observable.of(1,2);
Rx.Observable.of(1,2,3,4);
```



