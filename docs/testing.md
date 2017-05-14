# 测试

异步代码的测试通常很棘手。异步代码可能毫秒间完成，也能几分钟才完成。所以你需要一种方法来完全模仿它，就像你在 jasmine 中所做的一样。

```javascript
spyOn(service,'method').and.callFake(() => {
    return {
        then : function(resolve, reject){
            resolve('some data')
        }
    }
})
```

或简写版本:

```javascript
spyOn(service,'method').and.callFake(q.when('some data'))
```

要点是你尝试避免时间相关的东西。RxJS 是有历史的，`RxJS 4` 提供了一种方法，这种方法使用 TestScheduler 和它的内部时钟，这使你能够增强对时间的把控。这种方法有两种风格：

**方法 1**

```javascript
let testScheduler = new TestScheduler();

// 我的演示
let stream$ = Rx.Observable
.interval(1000, testScheduler)
.take(5);



// 设置测试
let result;

stream$.subscribe(data => result = data);


testScheduler.advanceBy(1000);
assert( result === 1 )

testScheduler.advanceBy(1000);
... 再次断言, 等等..
```

这种方法很容易理解。第二种方法使用热的 observable 和 `startSchedule()` 方法，看起来像这样：

```javascript
// 设置输出数据
var input = scheduler.createHotObservable(
    onNext(100, 'abc'),
    onNext(200, 'def'),
    onNext(250, 'ghi'),
    onNext(300, 'pqr'),
    onNext(450, 'xyz'),
    onCompleted(500)
  );

// 应用操作符
var results = scheduler.startScheduler(
    function () {
      return input.buffer(function () {
        return input.debounce(100, scheduler);
      })
      .map(function (b) {
        return b.join(',');
      });
    },
    {
      created: 50,
      subscribed: 150,
      disposed: 600
    }
  );

// 断言
collectionAssert.assertEqual(results.messages, [
    onNext(400, 'def,ghi,pqr'),
    onNext(500, 'xyz'),
    onCompleted(500)
  ]);
```

IMO 读起来有些费劲，但你仍然可以得到这个想法，你控制着时间，因为有 `TestScheduler` 来规定时间有多快。

这一切都是在 RxJS 4 进行的，在 RxJS 5 中有一些改变。我应该说，我要写下来的是一个大体的方向和一个前进的目标，所以这一章将会更新。我们开始吧。

在 RxJS 5 中使用的是叫做“弹珠测试(Marble Testing)”的东西。是的，这和[弹珠图](marble-diagrams)是有关系的，弹珠图就是用图形符号表达预期输入和实际输出。

我第一次看[官方文档的编写弹珠测试页面](https://github.com/ReactiveX/rxjs/blob/master/doc/writing-marble-tests.md)的时候，我完全是懵的，不知道应该怎么做。但是当我自己写了一些测试后，我得出一个结论，这是一种十分优雅的方法。

所以我会通过展示代码来进行说明：

```javascript
// 设置
const lhsMarble = '-x-y-z';
const expected = '-x-y-z';
const expectedMap = {
    x: 1,
    y: 2,
    z : 3
};

const lhs$ = testScheduler.createHotObservable(lhsMarble, { x: 1, y: 2, z :3 });

const myAlgorithm = ( lhs ) =>
    Rx.Observable
    .from( lhs );

const actual$ = myAlgorithm( lhs$ );

// 断言
testScheduler.expectObservable(actual$).toBe(expected, expectedMap);
testScheduler.flush();
```

我们分解来看

**设置**

```javascript
const lhsMarble = '-x-y-z';
const expected = '-x-y-z';
const expectedMap = {
    x: 1,
    y: 2,
    z : 3
};

const lhs$ = testScheduler.createHotObservable(lhsMarble, { x: 1, y: 2, z :3 });
```

我们基本上为 TestScheduler 上存在的方法 `createHotObservable()` 创建了一种模式指令 `-x-y-z`。`createHotObservable()` 是一个工厂方法，为我们做了大量的事情。作为对比，自己实现这个方法的话，在这个案例中相对应的应该像这样：

```javascript
let stream$ = Rx.Observable.create(observer => {
   observer.next(1);
   observer.next(2);
   observer.next(3);
})
```

我们不自己做的原因是我们想要 `TestScheduler` 来完成，这样时间就会根据其内部时钟流转。还要注意，我们定义一个预期模式和一个预期映射：

```javascript
const expected = '-x-y-z';

const expectedMap = {
    x: 1,
    y: 2,
    z : 3
}
```

那是我们需要的设置，但是要想测试运行起来还需要 `flush`，这样 `TestScheduler` 内部才可以触发 HotObservable 并运行断言。看下 `createHotObservable()` 方法的源码，我们发现它解析了我们给定的弹珠模式并添加到列表之中：

```javascript
// 摘自 createHotObservable
 var messages = TestScheduler.parseMarbles(marbles, values, error);
var subject = new HotObservable_1.HotObservable(messages, this);
this.hotObservables.push(subject);
return subject;
```

接下来是两个步骤的断言 1) expectObservable() 2) flush()

预期的调用差不多就是设置了 HotObservable 的订阅

```javascript
// 摘自 expectObservable()
this.schedule(function () {
    subscription = observable.subscribe(function (x) {
        var value = x;
        // 支持高阶 Observable 
        if (x instanceof Observable_1.Observable) {
            value = _this.materializeInnerObservable(value, _this.frame);
        }
        actual.push({ frame: _this.frame, notification: Notification_1.Notification.createNext(value) });
    }, function (err) {
        actual.push({ frame: _this.frame, notification: Notification_1.Notification.createError(err) });
    }, function () {
        actual.push({ frame: _this.frame, notification: Notification_1.Notification.createComplete() });
    });
}, 0);
```

通过定义一个内部的 `schedule()` 方法并调用它。断言的第二部分是断言本身：

```javascript
// 摘自 flush()
 while (readyFlushTests.length > 0) {
    var test = readyFlushTests.shift();
    this.assertDeepEqual(test.actual, test.expected);
}
```

最后将两个列表，`actual` 和 `expect` 进行比较。它执行的是深层次的比较并验证两件事，即数据发生在正确的时帧上和时帧上的值是正确的。所以这两个列表都包含如下所示的对象：

```javascript
{
  frame : [some number],
  notification : { value : [your value] }
}
```

这些属性都必须相等，那么断言才为真。

看起来没那么血腥吧？

## 符号

我还没有真正解释过我们所看到的：

```javascript
-a-b-c
```

但它实际上是有含义的。`-` 意味着流逝的时帧。`a` 只是个符号。所以你写了多少个实际的和预期的 `-`  是很重要的，因为它们需要匹配预期。来看下另一个测试，这样你能理解它并在这个过程中引入更多的符号：

```javascript
const lhsMarble = '-x-y-z';
const expected = '---y-';
const expectedMap = {
    x: 1,
    y: 2,
    z : 3
};

const lhs$ = testScheduler.createHotObservable(lhsMarble, { x: 1, y: 2, z :3 });

const myAlgorithm = ( lhs ) =>
    Rx.Observable
    .from( lhs )
    .filter(x => x % 2 === 0 );

const actual$ = myAlgorithm( lhs$ );

// 断言
testScheduler.expectObservable(actual$).toBe(expected, expectedMap);
testScheduler.flush();
```

在这个案例中，我们的演示包含了一个 `filter()` 操作。这意味着不会发出1,2,3，只有2会被发出。看下我们的输入模式：

```javascript
'-x-y-z'
```

And expected pattern

```javascript
`---y-`
```

And this is where you clearly see that no of `-` matters. Every symbol you write be it `-` or `x` etc happens at a certain time, so in this case when `x` and `z` wont occur due to the `filter()` method it means we just replace them with `-` in the resulting output so

```javascript
-x-y
```

becomes

```javascript
---y
```

because `x` doesn't happen.

There are of course other symbols that are of interest that lets us define things like an error. An error is denoted as a `#` and below follows an example of such a test:

```javascript
const lhsMarble = '-#';
const expected = '#';
const expectedMap = {
};

//const lhs$ = testScheduler.createHotObservable(lhsMarble, { x: 1, y: 2, z :3 });

const myAlgorithm = ( lhs ) =>
    Rx.Observable
    .from( lhs );

const actual$ = myAlgorithm( Rx.Observable.throw('error') );

//assert
testScheduler.expectObservable(actual$).toBe(expected, expectedMap);
testScheduler.flush();
```

And here is another symbol `|` representing a stream that completes:

```javascript
const lhsMarble = '-a-b-c-|';
const expected = '-a-b-c-|';
const expectedMap = {
    a : 1,
    b : 2,
    c : 3
};

const myAlgorithm = ( lhs ) =>
    Rx.Observable
    .from( lhs );

const lhs$ = testScheduler.createHotObservable(lhsMarble, { a: 1, b: 2, c :3 });    
const actual$ = lhs$;

testScheduler.expectObservable(actual$).toBe(expected, expectedMap);
testScheduler.flush();
```

and there are more symbols than that like `(ab)` essentially saying that these two values are emitted on the same time frame and so on. Now that you hopefully understand the basics of how symbols work I urge you to write your own tests to fully grasp it and learn the other symbols presented at the official docs page that I mentioned in the beginning of this chapter.

Happy testing
