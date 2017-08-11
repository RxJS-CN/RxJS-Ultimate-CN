# 工具

本章节的主题是罗列一些不错的公爵，可以帮助你来编写 RxJS 代码。

## RxJS 开发者工具

可以通过 GitHub 链接 [https://github.com/kwintenp/rx-devtools](https://github.com/kwintenp/rx-devtools) 找到它。README 列出了如何通过 npm/yarn 模块和 Chrome 插件来安装。

非常不错的可视化工具，可以很直观的看出代码做了那些事以及发出了什么值。

下面是如何在 Angular 项目中运行的代码:

```javascript
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

只需进入页面 [http://rxfiddle.net/#type=editor](http://rxfiddle.net/#type=editor) 并开始编写 RxJS 表达式即可。它会显示一个运行的视觉效果。没有比这更简单的了。