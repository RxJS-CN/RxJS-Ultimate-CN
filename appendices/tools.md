# Tools

The idea with this section is to list nice tools that helps you when writing RxJS code

## RxJS DevTools

Found on github link [https://github.com/kwintenp/rx-devtools](https://github.com/kwintenp/rx-devtools) The README lists how to install the the npm/ yarn module and also the chrome plugin.

Very nice tool for visualising what your code does and what values will be emitted.

Here is a code on how to run it inside of an Angular project:

```js
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/operator/filter';
import 'rxjs/add/operator/map';
import 'rxjs/add/operator/take';

export class AppComponent {
  constructor() {
    const interval$ = Observable.interval(1000)
      .debug('test map')
      .startWith(10)
      .take(10)
      .filter((val: number) => val % 2 > 0)
      .map((val: number) => val * 2)
      .subscribe();
  }
}
```

## RxFiddle

Just go to the page [http://rxfiddle.net/\#type=editor](http://rxfiddle.net/#type=editor) and start writing your RxJS expressions. It will show you a visual of what a run looks like. It doesn't get any simpler.

