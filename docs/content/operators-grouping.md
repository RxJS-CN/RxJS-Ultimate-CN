# 分组操作符

## buffer

`buffer()` 操作符的函数签名：

```javascript
buffer([breakObservable])
```

`buffer` 本身意味着我们在等待而不会发出任何值，直到 `breakObservable` 发生。示例如下：

```javascript
let breakWhen$ = Rx.Observable.timer(1000);

let stream$ = Rx.Observable.interval(200)
.buffer( breakWhen$ );

stream$.subscribe((data) => console.log( 'values',data ));
```

在这个案例中会一次性地发出值： `values 0,1,2,3` 。

### 业务场景

**Auto complete(自动完成/智能提示)** - 使用 `buffer()` 操作符进行处理的最显著的例子就是 `auto complete` 。但 `auto complete` 是如何工作的呢？我们来分步骤看下

  * 用户输入关键字
  * 搜索是基于这些按键的。重要的是，搜索本身是在打字时执行的，要么就执行多次，因为你输入了x个字符，要么采用更普遍的处理方式，就是打字完成后再执行搜索，还可以在输入时进行编辑。那么我们来执行这套解决方案的第一步：

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'keyup' )

let breakWhen$ = Rx.Observable.timer(1000);
let debounceBreak$ = input$.debounceTime( 2000 );

let stream$ = input$
.map( ev => ev.key )
.buffer( debounceBreak$ );

stream$.subscribe((data) => console.log( 'values',data ));
```

我们捕获 `keyup` 事件。我们还使用了 `debounce()` 操作符，本质上来说，一旦你停止打字x毫秒后它才会发出值。这个解决方案只是进行中的第一步，因为它只是报告了具体敲击的按键。一个更好的解决方案是捕获输入元素的实际内容，还可以执行 ajax 调用，所以让我们来看一个更精致的解决方案：

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'keyup' )

let breakWhen$ = Rx.Observable.timer(1000);
let debounceBreak$ = input$.debounceTime( 2000 );

let stream$ = input$
.map( ev => {
    return ev.key })
.buffer( debounceBreak$ )
.switchMap((allTypedKeys) => {
    // 执行 ajax
    console.log('Everything that happened during 2 sec', allTypedKeys)
    return Rx.Observable.of('ajax based on ' + input.value);
});

stream$.subscribe((data) => console.log( 'values',data ));
```

这个称之为“增强的 auto complete” 。原因如名字一样，我们保存了用户所做的每一个交互，然后才最终决定应该成为 Ajax 调用的最终输入。所以上面代码的结果应该看起来像下面这样：

```javascript
// 出自 switchMap
Everything that happened during 2 sec ["a", "a", "a", "Backspace", "Backspace", "Backspace", "Backspace", "b", "b", "Backspace", "Backspace", "Backspace", "f", "g", "h", "f", "h", "g"]

// 出自 subscribe
values ajax based on fghfgh
```

如你所见，其实我们可以储存大量用户潜在的信息，而不只是做了 auto complete 搜索，我们可以储存他们是如何打字的，这或许很有趣，亦或是很无聊...

**双击** - 在上面的示例中，我已经展示了按组捕获按键可以很有趣，而另一组可能有趣的 UI 事件就是鼠标点击事件，即单击、双击或三连击。如果不用 RxJS 的话，那写出的代码是极不优雅的，反之则轻而易举，像下面这样：

```javascript
let btn = document.getElementById('btn2');
let btn$  = Rx.Observable.fromEvent( btn, 'click' )

let debounceMouseBreak$ = btn$.debounceTime( 300 );

let btnBuffered$ = btn$
.buffer( debounceMouseBreak$ )
.map( array => array.length )
.filter( count => count >= 2 )
;

btnBuffered$.subscribe((data) => console.log( 'values',data ));
```

多亏 `debounce()` 操作符，我们可以在发出任何值之前表达等待300毫秒。只是短短几行代码，就让我们很容易的可以决定 filter 应该怎么写。

## bufferTime

`bufferTime()` 的函数签名：

```javascript
bufferTime([ms])
```

作用是记录在该时间段内发生的所有事情并输出所有的值。下面的示例是以1秒为时间片段记录输入的所有活动事件。

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'input' )
.bufferTime(1000);

input$.subscribe((data) => console.log('all inputs in 1 sec', data));
```

在这个案例中你得到的输出会是这样的：

```javascript
all inputs in 1 sec [ Event, Event... ]
```

得到的数据似乎没什么用，所以我们可能需要使用 `map()` 来使数据变得清晰，以便于看到用户实际的按键，像这样：

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'keyup' )
.map( ev => ev.key)
.bufferTime(1000);

input$.subscribe((data) => console.log('all inputs in 1 sec', data));
```

还要注意一点，我把事件改成了 `keyup` 。现在我们可以看见1秒内发生的所有 `keyup` 事件。

### 业务场景

如果你想要记录该网站上的其它用户正在做什么，并希望重播他们曾经做过的所有交互，或者当他们开始输入，你希望通过 socket 发送此信息的话，那么上面的示例会非常有用。最后一个是当下的标准功能，你看见一个人在另一个终端上打字。所以确实有这样的业务案例。

## groupBy

TODO
