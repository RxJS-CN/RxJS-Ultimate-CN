# Operators

Operators are what gives Observables their power. Without them they are nothing. There are close to 60+ operators

Let's look at some:

## of

```javascript
let stream$ = Rx.Observable.of(1,2,3,4,5)
```

Right here we are using a creation type operator to create an observable for us. This is synchronous in nature and outputs the values as soon as possible. Essentially it lets you specify what values to emit in a comma separated list.

## do

```javascript
let stream$ =
Rx.Observable
  .of(1,2,3)
  .do((value) => {
    console.log('emits every value')
  });
```

This is a very handy operator as it is used for debugging of your Observable.

## filter

```javascript
let stream$ =
Rx.Observable
.of(1,2,3,4,5)
.filter((value) => {
  return value % 2 === 0;
})

// 2,4
```

So this stops certain values from being emitted

Notice however that I can add the do operator in a handy place and can still investigate all the values

```javascript
let stream$ =
Rx.Observable
.of(1,2,3,4,5)
.do((value) => {
  console.log('do',value)
})
.filter((value) => {
  return value % 2 === 0;
})

stream$.subscribe((value) => {
  console.log('value', value)
})

//  do: 1,do : 2, do : 3, do : 4, do: 5
// value : 2, 4
```
