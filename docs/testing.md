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

We essentially create a pattern instruction `-x-y-z` to the method `createHotObservable()` that exist on our TestScheduler. This is a factory method that does some heave lifting for us. Compare this to writing this by yourself, in which case it corresponds to something like:

```javascript
let stream$ = Rx.Observable.create(observer => {
   observer.next(1);
   observer.next(2);
   observer.next(3);
})
```

The reason we don't do it ourselves is that we want the `TestScheduler` to do it so time passes according to its internal clock. Note also that we define an expected pattern and an expected map:

```javascript
const expected = '-x-y-z';

const expectedMap = {
    x: 1,
    y: 2,
    z : 3
}
```

Thats what we need for the setup, but to make the test run we need to `flush` it so that `TestScheduler` internally can trigger the HotObservable and run an assert. Peeking at `createHotObservable()` method we find that it parses the marble patterns we give it and pushes it to list:

```javascript
// excerpt from createHotObservable
 var messages = TestScheduler.parseMarbles(marbles, values, error);
var subject = new HotObservable_1.HotObservable(messages, this);
this.hotObservables.push(subject);
return subject;
```

Next step is assertion which happens in two steps 1) expectObservable() 2) flush()

The expect call pretty much sets up a subscription to out HotObservable

```javascript
// excerpt from expectObservable()
this.schedule(function () {
    subscription = observable.subscribe(function (x) {
        var value = x;
        // Support Observable-of-Observables
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

by defining an internal `schedule()` method and invoking it. The second part of the assert is the assertion itself:

```javascript
// excerpt from flush()
 while (readyFlushTests.length > 0) {
    var test = readyFlushTests.shift();
    this.assertDeepEqual(test.actual, test.expected);
}
```

It ends up comparing two lists to each other, the `actual` and `expect` list. It does a deep compare and verifies two things, that the data happened on the correct time frame and that the value on that `frame` is correct. So both lists consist of objects that looks like this:

```javascript
{
  frame : [some number],
  notification : { value : [your value] }
}
```

Both these properties must be equal for the assert to be true.

Doesn't seem that bloody right?

## Symbols

I havn't really explained what we looked at with:

```javascript
-a-b-c
```

But it actually means something. `-` means a time frame passed. `a` is just a symbol. So it matters how many `-` you write in actual and expected cause they need to match. Let's look at another test so you get the hang of it and to introduce more symbols:

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

//assert
testScheduler.expectObservable(actual$).toBe(expected, expectedMap);
testScheduler.flush();
```

In this case our algorithm consists of a `filter()` operation. Which means 1,2,3 will not be emitted only 2. Looking at the ingoing pattern we have:

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
