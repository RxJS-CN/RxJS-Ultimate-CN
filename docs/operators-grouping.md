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

Let's call this one `auto complete on steroids`. The reason for the name is that we save every single interaction the user does before finally deciding on the final input that should become an Ajax call. So a result from the above could look like the following:

```javascript
// from switchMap
Everything that happened during 2 sec ["a", "a", "a", "Backspace", "Backspace", "Backspace", "Backspace", "b", "b", "Backspace", "Backspace", "Backspace", "f", "g", "h", "f", "h", "g"]

// in the subscribe(fnValue)
app-buffer.js:31 values ajax based on fghfgh
```

As you can see we could potentially store a whole lot more about a user than just the fact that they made an auto complete search, we can store how they type and that may or may not be interesting..

**Double click** In the example above I've showed how it could be intersting to capture groups of keys but another group of UI events of possible interests are mouse clicks, namely for capturing single, double or triple clicks. This is quite inelegant code to write if not in Rxjs but with it, it's a breeze:

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

Thanks to the `debounce()` operator we are able to express wait for 300ms before emitting anything. This is quite few lines and it's easy for us to decide what our filter should look like.

## bufferTime

The signature of `bufferTime()` is

```javascript
bufferTime([ms])
```

The idea is to record everything that happens during that time slice and output all the values. Below is an example of recording all activities on an input in 1 second time slices.

```javascript
let input = document.getElementById('example');
let input$  = Rx.Observable.fromEvent( input, 'input' )
.bufferTime(1000);

input$.subscribe((data) => console.log('all inputs in 1 sec', data));
```

In this case you will get an output looking like:

```javascript
all inputs in 1 sec [ Event, Event... ]
```

Not so usable maybe so we probably need to make it nice with a `filter()` to see what was actually typed, like so:

### Business case

The example above could be quite usable if you want to record what another user on the site is doing and want to replay all the interactions they ever did or if they started to type and you want to send this info over a socket. The last is something of a standard functionality nowadays that you see a person typing on the other end. So there are definitely use cases for this.

## groupBy

TODO
