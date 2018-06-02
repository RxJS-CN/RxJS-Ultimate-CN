# Installation and Setup

The content for this chapter is taken from the offical docs but I am trying to provide you with a little more information as to why and also its nice to have everything in one place. [Official docs](https://github.com/ReactiveX/rxjs)

TH Rxjs lib can be consumed in many different ways, namely `ES6`, `CommonJS` and as `ES5/CDN`.

## ES6

### Install

```
npm install rxjs
```

### Setup

```
import { of } from 'rxjs';

of(1,2,3)
```

### GOTCHA

This statement `import Rx from 'rxjs/Rx'` utilizes the entire library. It is great for testing out various features but once hitting production this is *a bad idea* as Rxjs is quite a heavy library. In a more realistic scenario you would want to use the alternate approach below that only imports the operators that you actually use :

```
import { of } from 'rxjs';
import { map } from "rxjs/operators";

let stream$ = of(1,2,3).pipe(
  map(x => x + '!!!')
) 

stream$.subscribe((val) => {
  console.log(val) // 1!!! 2!!! 3!!!
})
```

## CommonJS

Same install as with ES6

### Install

```
npm install rxjs
```

### Setup

Setup is different though

Below is yet again showcasing the greedy import that is great for testing but bad for production

```
var { of } = require('rxjs');

of(1,2,3); // etc
```

And the better approach here being:

```
var { of } = require('rxjs');
const { map } = require('rxjs/operators');

of(1,2,3).pipe(
  map((x) => { return x + '!!!'; })
) // etc
```

As you can see we go about it a little differently when we grab the `of` operator. It looks pretty much the same when we drill down to get the `map` operator. 

Notice that we will most likely find the operator we need from `rxjs/operators` and that we no longer use an `Observable` object

## CDN or ES5

If I am on neither ES6 or CommonJS there is another approach namely:

```
<script src="https://unpkg.com/rxjs/bundles/Rx.min.js"></script>
```

Notice however this will give you the full lib. As you are requiring it externally it won't affect your bundle size though.

