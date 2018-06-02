#Operators

Operators are what gives Observables their power. Without them they are nothing. There are close to 60+ operators

Let's look at some:

##of 

```
import { of } from 'rxjs';

let stream$ = of(1,2,3,4,5);

```
Right here we are using a creation type operator to create an observable for us. This is synchronous in nature and outputs the values as soon as possible. Essentially it lets you specify what values to emit in a comma separated list.

## tap

```
import { of } from 'rxjs';
import { tap } from 'rxjs/operators';

let stream$ = of(1,2,3).pipe(
  tap((value) => {
    console.log('emits every value')
  })
);

```
This is a very handy operator as it is used for debugging of your Observable.

## filter

```
import { of } from 'rxjs';
import { filter } from 'rxjs/operators';

let stream$ = of(1,2,3,4,5).pipe(
  filter((value) => {
    return value % 2 === 0;
  })
)

// 2,4
```
So this stops certain values from being emitted

Notice however that I can add the `do` operator in a handy place and can still investigate all the values

```
import { of } from 'rxjs';
import { tap, filter } from 'rxjs/operators';

let stream$ = of(1,2,3,4,5).pipe(
  tap((value) => {
    console.log('tap',value)
  }),
  filter((value) => {
    return value % 2 === 0;
  })
);

stream$.subscribe((value) => {
  console.log('value', value)
})

//  tap: 1,tap : 2, tap : 3, tap : 4, tap: 5 
// value : 2, 4
```



