# 时间操作符

这可不是一个简单的话题。其中涉及了应用程序中的诸多领域，你可能想要同步 API 的响应，或者你想要处理其它类型的流，比如 UI 中的点击事件或键盘事件。

有大量的操作符以它们各自的方式来处理时间，比如 `delay`、 `debounce`、 `throttle`、 `interval`， 等等。

## interval

这个操作符用来创建一个 Observable，基本上它所做的就是按固定的时间间隔提供值，函数签名如下：

```javascript
Rx.Observable.interval([ms])
```

示例用法:

```javascript
Rx.Observable.interval(100)

// 无限生成下去
```

因为这个操作符会不停地生成值，所以倾向于和 `take()` 操作符一起使用，这样可以在调用它之前限制生成值的数量，就像这样：

```javascript
Rx.Observable.interval(1000).take(3)

// 生成 1,2,3
```

## timer

`timer` 是个有趣的操作符，它可以有多种行为，这取决于你如何使用它。它的函数签名是

```javascript
Rx.Observable.timer([initial delay],[thereafter])
```

然后只有第一个参数是必须的，所以取决于使用参数的数量，它会有不同的用法。

**一次性的**

```javascript
let stream$ = Rx.Observable.timer(1000);

stream$.subscribe(data => console.log(data));

// 1秒后生成0
```

这样就是一次性的，因为并没有规定何时发出下一个值。

**指定第二个参数**

```javascript
let moreThanOne$ = Rx.Observable.timer(2000, 500).take(3);

moreThanOne$.subscribe(data => console.log('timer with args', data));

// 2秒后生成0，然后再500毫秒后生成1，然后再500毫秒生成2
```

这样更灵活一些，会根据第二个参数持续性的发出值。

## delay

`delay()` 操作符只是简单地延迟每个要发出的值，它是这样使用的：

```javascript
var start = new Date();
let stream$ = Rx.Observable.interval(500).take(3);

stream$
.delay(300)
.subscribe((x) => {
    console.log('val',x);
    console.log( new Date() - start );
})

// 800ms左右后输出 0 , 1300ms左右后输出1, 1800ms左后后输出2
```

### 业务场景

`delay` 操作符可以在很多地方使用，但其中一个很好的场景是异常处理，尤其是当网络不稳定时我们想要在x毫秒后重试整个流：

想了解更多，请阅读[异常处理](error-handling.md)章节

## sampleTime

我通常认为这个场景可以称之为“懒得理你”。我的意思是事件只会在特定的时间点被触发。

### 业务场景

所以在x毫秒内的忽略事件的能力是非常有用的。想象一下，一个保存按钮被狂点N次，只在x毫秒后只有最近的一次点击生效而忽略其它的点击不是很好吗？

```javascript
const btn = document.getElementById('btnIgnore');
var start = new Date();

const input$ = Rx.Observable
  .fromEvent(btn, 'click')

  .sampleTime(2000);

input$.subscribe(val => {
  console.log(val, new Date() - start);
});
```

上面的代码所做的就是这件事。

## debounceTime

`debounceTime()` 操作符会告诉你：我只会以一定的时间间隔发出数据，而不会一直发出数据。

### 业务场景

Debounce 是一个已知的概念，特别是当你敲击键盘的时候。就像是在说，我们不在乎你的每次敲击键盘，但是一旦你停止打字后的一段时间是我们所关心的。一个普通的 auto complete (自动完成/智能提示) 就应该在这个时候开始启动了。如果说你的用户停止打字已经有x毫秒了，通常这意味着我们应该执行一次 ajax 调用并取回结果。

```javascript
const input = document.getElementById('input');

const example = Rx.Observable
  .fromEvent(input, 'keyup')
  .map(i => i.currentTarget.value);

//wait 0.5s, between keyups, throw away all other values
const debouncedInput = example.debounceTime(500);

const subscribe = debouncedInput.subscribe(val => {
  console.log(`Debounced Input: ${val}`);
});
```

The following only outputs a value, from our input field, after you stopped typing for 500ms, then it's worth reporting about it, i.e emit a value.

## throttleTime

TODO

## buffer

This operator has the ability to record x number of emitted values before it outputs its values, this one comes with one or two input parameters.

```javascript
.buffer( whenToReleaseValuesStartObservable )

or

.buffer( whenToReleaseValuesStartObservable, whenToReleaseValuesEndObservable )
```

So what does this mean? It means given we have for example a click of streams we can cut it into nice little pieces where every piece is equally long. Using the first version with one parameter we can give it a time argument, let's say 500 ms. So something emits values for 500ms then the values are emitted and another Observable is started, and the old one is abandoned. It's much like using a stopwatch and record for 500 ms at a time. Example :

```javascript
let scissor$ = Rx.Observable.interval(500)

let emitter$ = Rx.Observable.interval(100).take(10) // output 10 values in total
.buffer( scissor$ )

// [0,1,2,3,4] 500ms [5,6,7,8,9]
```

Marble diagram

```
--- c --- c - c --- >
-------| ------- |- >
Resulting stream is :
------ r ------- r r  -- >
```

### Business case

So whats the business case for this one? `double click`, it's obviously easy to react on a `single click` but what if you only want to perform an action on a `double click` or `triple click`, how would you write code to handle that? You would probably start with something looking like this :

```javascript
$('#btn').bind('click', function(){
  if(!start) { start = timer.start(); }
  timePassedSinceLastClickInMs = now - start;
  if(timePassedSinceLastClickInMs < 250) {
     console.log('double click');

  } else {
     console.log('single click')
  }

  start = timer.start();  
})
```

Look at the above as an attempt at pseudo code. The point is that you need to keep track of a bunch of variables of how much time has passed between clicks. This is not nice looking code, lacks elegance

#### Model in Rxjs

By now we know Rxjs is all about streams and modeling values over time. Clicks are no different, they happen over time.

```
---- c ---- c ----- c ----- >
```

We however care about the clicks when they appear close together in time, i.e as double or triple clicks like so :

```
--- c - c ------ c -- c -- c ----- c
```

From the above stream you should be able to deduce that a `double click`, one `triple click` and one `single click` happened.

So let's say I do, then what? You want the stream to group itself nicely so it tells us about this, i.e it needs to emit these clicks as a group. `filter()` as an operator lets us do just that. If we define let's say 300ms is a long enough time to collect events on, we can slice up our time from 0 to forever in chunks of 300 ms with the following code:

```javascript
let clicks$ = Rx.Observable.fromEvent(document.getElementById('btn'), 'click');

let scissor$ = Rx.Observable.interval(300);

clicks$.buffer( scissor$ )
      //.filter( (clicks) => clicks.length >=2 )
      .subscribe((value) => {
          if(value.length === 1) {
            console.log('single click')
          }
          else if(value.length === 2) {
            console.log('double click')
          }
          else if(value.length === 3) {
            console.log('triple click')
          }

      });
```

Read the code in the following way, the buffer stream, `clicks$` will emit its values every 300ms, 300 ms is decided by `scissor$` stream. So the `scissor$` stream is the scissor, if you will, that cuts up our click stream and voila we have an elegant `double click` approach. As you can see the above code captures all types of clicks but by uncommenting the `filter()` operation we get only `double clicks` and `triple clicks`.

`filter()` operator can be used for other purposes as well like recording what happened in a UI over time and replay it for the user, only your imagination limits what it can be used for.
