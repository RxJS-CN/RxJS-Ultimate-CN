# 安装设置

本章的内容取自官方文档，但我尝试为你提供一些更多的信息以了解为什么，而且将所有内容都放在一个位置也是个不错的选择。[官方文档](https://github.com/ReactiveX/rxjs)

RxJS 库可以以多种不同的方式来使用，即 `ES6`、`CommonJS` 和 `ES5/CDN` 。

## ES6

### 安装

```shell
npm install rxjs
```

### 设置

```javascript
import Rx from 'rxjs/Rx';

Rx.Observable.of(1,2,3)
```

### 陷阱

`import Rx from 'rxjs/Rx'` 语句会导入整个库。对于测试各种特性这很方便，但对于生产环境这就不是一个好主意了，因为 RxJS 本身是个重量级的库。在一个更现实的场景中，你可能想要使用下面这种方式，只导入实际要使用的操作符：

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

### 安装

```shell
npm install rxjs
```

### 设置

设置是不同的

下面再次展示了对于测试非常便利的全部导入，但不适合在生产环境中使用

```javascript
var Rx = require('rxjs/Rx');

Rx.Observable.of(1,2,3); // 等等
```

更好的方式:

```javascript
let Observable = require('rxjs/Observable').Observable;
// 使用适合的方法为 Observable 打补丁
require('rxjs/add/observable/of');
require('rxjs/add/operator/map');

Observable.of(1,2,3).map((x) => { return x + '!!!'; }); // 等等
```

如你所见，`require('rxjs/Observable')` 只提供了 Rx 对象，而我们需要深入到下一层级以找到 Observable 。

注意 `require('path/to/operator')` 用来获取应用中所需要导入的操作符。

## CDN 或 ES5

如果我用的既不是 ES6，也不是 CommonJS 的话，那么还有另外一种方式：

```html
<script src="https://unpkg.com/rxjs/bundles/Rx.min.js"></script>
```

注意，这会引入完整的库。因为是从外部引用的，所以不会影响 bundle 的大小。
