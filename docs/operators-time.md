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

// 800毫秒左右后输出 0 , 1300毫秒左右后输出1, 1800毫秒左后后输出2
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

// 在两次敲击键盘事件之间，有0.5秒的等待时间，如果时间小于0.5秒则丢弃前一个敲击键盘事件
const debouncedInput = example.debounceTime(500);

const subscribe = debouncedInput.subscribe(val => {
  console.log(`Debounced Input: ${val}`);
});
```

上面的代码只会输出一个值，值来源于 input 表单，在你停止打字后的500毫秒后，才值得它报告一下，也就是发出一个值。

## throttleTime

TODO

## buffer

`buffer` 操作符的能力是在输出它的值前记录x个发出的值，它可以使用一个或两个参数。

```javascript
.buffer( whenToReleaseValuesStartObservable )

或

.buffer( whenToReleaseValuesStartObservable, whenToReleaseValuesEndObservable )
```

那么这意味着什么呢？它的意思是，如果我们有一个点击流的话，可以将其我切成漂亮的小块流，每一小块流包含的事件的数量都是相同的。使用一个参数的话，我们可以给它一个时间参数(译者注: 这里说时间参数可能不太准确，会让人联想到500毫秒这样的参数，应该是时间相关的 Observable，比如 interval 操作符生成的)，假设是500毫秒。所以原本要发出的值会积攒500毫秒后发出，然后另一个 Observable 会开启，老的 Observable 则被抛弃。这很像是在使用秒表，一次记录500毫秒。示例：

```javascript
let scissor$ = Rx.Observable.interval(500)

let emitter$ = Rx.Observable.interval(100).take(10) // 总共会输出10个值
.buffer( scissor$ )

// 500毫秒后输出: [0,1,2,3,4]  1秒后输出: [5,6,7,8,9]
```

弹珠图

```
--- c --- c - c --- >
-------| ------- |- >
结果流是 :
------ r ------- r r  -- >
```

### 业务场景

那么 `buffer` 的业务场景到底是什么？ 那就是双击，对单击作出响应显然是很简单的，但如果只想对双击或是三连击进行处理，又应该如何用代码来处理呢？你可能会用类似下面的方法来处理：

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

看下上面的伪代码。关键是你需要记录一些在点击之间的时间变量。这样的代码缺乏优雅性，不能算是一种好的代码

#### 在 RxJS 中建模

到目前为止，对于 RxJS 我们所知道的一切都是关于流和随着时间的推移对值进行建模。点击没什么不同，它们也是随着时间的推移而产生。

```
---- c ---- c ----- c ----- >
```

然而，我们关心的是短时间内接连出现的点击，即像下面这样的双击或三连击：

```
--- c - c ------ c -- c -- c ----- c
```

从上面的流中你应该可以推断出发生了一次双击、一次三连击和一次单击。

假设我就是这么做的，那么然后呢？你希望流自己分组，以便告诉我们这一点，即需要将哪些点击作为一个组发出。`filter()` 操作符可以帮我们完成任务。如果我们定义了一个足够长的时间(假设是300毫秒)来收集事件，可以使用下面的代码将时间从0到永远以300毫秒的时间块进行分割：

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
