# 安装设置

本章的内容取自官方文档，但我尝试为你提供一些更多的信息以了解为什么，而且将所有内容都放在一个位置也是个不错的选择。[官方文档](https://github.com/ReactiveX/rxjs)

RxJS 库可以以多种不同的方式来使用，即 `ES6`、`CommonJS` 和 `ES5/CDN` 。

## ES6

### 安装

```shell
npm install Rxjs
```

### 设置

```javascript
import Rx from 'rxjs/Rx';

Rx.Observable.of(1,2,3)
```

### 陷阱

`import Rx from 'rxjs/Rx'` 语句会导入整个库。对于测试各种特性这很方便，但对于生产环境这就不是一个好主意了，因为 RxJS 本身是个重量级的库。在一个更现实的场景中，你可能想要使用下面这种方案，只导入实际要使用的操作符：

```javascript
import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/of';
import 'rxjs/add/operator/map';

let stream$ = Observable.of(1,2,3).map(x => x + '!!!');

stream$.subscribe((val) => {
  console.log(val) // 1!!! 2!!! 3!!!
})
```

## CommonJS

安装方法同 ES6

### Install

```shell
npm install Rxjs
```

### Setup

Setup is different though

Below is yet again showcasing the greedy import that is great for testing but bad for production

```javascript
var Rx = require('rxjs/Rx');

Rx.Observable.of(1,2,3); // etc
```

And the better approach here being:

```javascript
let Observable = require('rxjs/Observable').Observable;
// patch Observable with appropriate methods
require('rxjs/add/observable/of');
require('rxjs/add/operator/map');

Observable.of(1,2,3).map((x) => { return x + '!!!'; }); // etc
```

As you can see require('rxjs/Observable') just gives us the Rx object and we need to dig one level down to find the Observable.

Notice also we just require('path/to/operator') to get the operator we want to import for our app.

## CDN or ES5

If I am on neither ES6 or CommonJS there is another approach namely:

```html
<script src="https://unpkg.com/rxjs/bundles/Rx.min.js"></script>
```

Notice however this will give you the full lib. As you are requiring it externally it won't affect your bundle size though.
