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

import Rx from 'rxjs/Rx';

Rx.Observable.of(1,2,3)

```

### GOTCHA 

This statement `import Rx from 'rxjs/Rx'` utilizes the entire library. It is great for testing out various features but once hitting production this is *a bad idea* as Rxjs is quite a heave library. In a more realistic scenario you would want to use the alternate approach below that only imports the operators that you actually use :
```

import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';
import 'rxjs/add/operator/map';

let stream$ = Observable.of(1,2,3).map(x => x + '!!!'); 

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
var Rx = require('rxjs/Rx');

Rx.Observable.of(1,2,3); // etc

```

And the better approach here being:
```

let Observable = require('rxjs/Observable').Observable;
// patch Observable with appropriate methods
require('rxjs/add/observable/of');
require('rxjs/add/operator/map');

Observable.of(1,2,3).map((x) => { return x + '!!!'; }); // etc

```

As you can see `require('rxjs/Observable')` just gives us the Rx object and we need to dig one level down to find the Observable.

Notice also we just `require('path/to/operator')` to get the operator we want to import for our app.

## CDN or ES5

If I am on neither ES6 or CommonJS there is another approach namely:
```

<script src="https://unpkg.com/rxjs/bundles/Rx.min.js"></script>

```

Notice however this will give you the full lib. As you are requiring it externally it won't affect your bundle size though.



