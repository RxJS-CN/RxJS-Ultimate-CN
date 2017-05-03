# 操作符和 Ajax

这是 Rx 对象上的 `ajax` 操作符。

## 使用 ajax() 操作符

index.html

```html
<html>
    <body>
        <div id="result">

        </div>
        <script src="https://unpkg.com/@reactivex/rxjs@5.0.1/dist/global/Rx.js"></script>
        <script src="app.js"></script>
    </body>
</html>
```

app.js

```javascript
let person$ = Rx.Observable
  .ajax({
      url : 'http://swapi.co/api/people/1',
      crossDomain: true,
      createXHR: function () {
        return new XMLHttpRequest();
     }
    })
  .map(e => e.response);

const subscription = person$
  .subscribe(res => {
      let element = document.getElementById('result');
      element.innerHTML = res.name
      console.log(res)
  });
```

有一点坑的是我们调用 `ajax()` 操作符的方式，除了 `url` 属性外我们显示地指定了一堆配置。这样做的原因是 `ajax` 操作符内部是这样运行的：

> 执行 ajaxObservable 中的 XHR 的默认工厂函数，并把 withCredentials 默认设置为 true

所以我们给定了一个自定义工厂函数而且它可以正常运行。我明白目前这也被看做是一个 issue

## 使用 fetch API

```javascript
const fetchSubscription = Rx.Observable
.from(fetch('http://swapi.co/api/people/1'))
.flatMap((res) => Rx.Observable.from(res.json()) )
.subscribe((fetchRes) => {
    console.log('fetch sub', fetchRes);
})
```

这里有几件事情值得一提

* fetch api 是基于 promise 的，然而使用 `.from()` RxJS 允许我们输入一个 promise 作为参数并将其转换为 Observable 。
* 请求回来的结果是一个 `response` 对象，需要将它转换成 JSON 。调用 `json()` 方法可以完成这项工作，但 `json()` 返回的也是 Promise 。所以我们需要再次使用 `from()` 操作符。但在一个 Observable 内再创建一个 Observable 的话会形成嵌套的 Observable，这不是我们想要的，我们要的只是 JSON 。所以我们使用一个叫做 `flatMap()` 的操作符来修复它。想深入了解 `flatMap()`，请参加[这里](operators-observable-in-an-observable.md)

最终我们得到了预期的 JSON，如果要跨域请求接口的话，fetch 还需要进行额外的配置。
