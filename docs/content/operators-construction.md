# 创建操作符

## create

当你刚起步或者只是想要测试一些东西时，倾向于从 `create()` 操作符入手。它接收一个有 `observer` 参数的函数。在前面的一些章节中已提及过，比如 [Observable 包装](observable-wrapping.md)章节。函数签名如下：

```javascript
Rx.Observable.create([fn])
```

示例如下：

```javascript
Rx.Observable.create(observer => {
    observer.next( 1 );
})
```

## range

函数签名

```javascript
Rx.Observable.range([start],[count])
```

示例

```javascript
let stream$ = Rx.Observable.range(1,3)

// 发出 1,2,3
```
