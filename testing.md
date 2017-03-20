#Testing 
Testing of async code is generally quite tricky. Async code may finish in ms or even minutes. So you need a way to either mock it away completely like for example you do with jasmine.

```
spyOn(service,'method').and.callFake(() => {
    return {
        then : function(resolve, reject){
            resolve('some data')
        }
    }
})
```
or a more shorthand version:

```
spyOn(service,'method').and.callFake(q.when('some data'))

```

Point is you try to avoid the whole timing thing. Rxjs have historically, in `Rxjs 4` provided the approach of using a TestScheduler with its own internal clock, which has enabled you to increment time. This approach have had two flavors :

**Approach 1 **

```
let testScheduler = new TestScheduler();

// my algorithm
let stream$ = Rx.Observable
.interval(1000, testScheduler)
.take(5);



// setting up the test
let result;

stream$.subscribe(data => result = data);


testScheduler.advanceBy(1000);
assert( result === 1 )

testScheduler.advanceBy(1000);
... assert again, etc.. 

```

This approach was pretty easy to grok. The second approach was using hot observables and a `startSchedule()` method, looking something like this :

```
// setup the thing that outputs data
var input = scheduler.createHotObservable(
    onNext(100, 'abc'),
    onNext(200, 'def'),
    onNext(250, 'ghi'),
    onNext(300, 'pqr'),
    onNext(450, 'xyz'),
    onCompleted(500)
  );
  
// apply operators to it
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
  
//assert
collectionAssert.assertEqual(results.messages, [
    onNext(400, 'def,ghi,pqr'),
    onNext(500, 'xyz'),
    onCompleted(500)
  ]);      
```

A little harder to read IMO but you still get the idea, you control time because you have a `TestScheduler` that dictates how fast time should pass.

This is all Rxjs 4 and it has changed a bit in Rxjs 5. I should say that what I am about to write down is a bit of a general direction and a moving target so this chapter will be updated, but here goes.  

In Rxjs 5 something called `Marble Testing` is used. Yes that is related to [Marble Diagram](/marble-diagrams.md) i.e you express your expected input and actual output with graphical symbols.

First time I had a look at the  [offical docs page](https://github.com/ReactiveX/rxjs/blob/master/doc/writing-marble-tests.md) I was like *What now with a what now?*. But after writing a few tests myself I came to the conclusion this is a pretty elegant approach. 

So I will explain it by showing you code:

```
// setup
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

//assert
testScheduler.expectObservable(actual$).toBe(expected, expectedMap);
testScheduler.flush();
```  
Let's break it down part by part

**Setup**
```
const lhsMarble = '-x-y-z';
const expected = '-x-y-z';
const expectedMap = {
    x: 1,
    y: 2,
    z : 3
};

const lhs$ = testScheduler.createHotObservable(lhsMarble, { x: 1, y: 2, z :3 });
```
We essentially create a pattern instruction `-x-y-z` to the method `createHotObservable()` that exist on our `TestScheduler`. This is a factory method that does some heave lifting for us. Compare this to writing this by yourself, in which case it corresponds to something like:

```
let stream$ = Rx.Observable.create(observer => {
   observer.next(1);
   observer.next(2);
   observer.next(3);
})
```
The reason we don't do it ourselves is that we want the `TestScheduler` to do it so time passes according to its internal clock. Note also that we define an expected pattern and an expected map:

```
const expected = '-x-y-z';

const expectedMap = {
    x: 1,
    y: 2,
    z : 3
}
```
Thats what we need for the setup, but to make the test run we need to `flush` it so that `TestScheduler` internally can trigger the HotObservable and run an assert. Peeking at `createHotObservable()` method we find that it parses the marble patterns we give it and pushes it to list:

```
// excerpt from createHotObservable
 var messages = TestScheduler.parseMarbles(marbles, values, error);
var subject = new HotObservable_1.HotObservable(messages, this);
this.hotObservables.push(subject);
return subject;
```

Next step is assertion which happens in two steps 
1) expectObservable()
2) flush()

The expect call pretty much sets up a subscription to out HotObservable

```
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
by defining an internal `schedule()` method and invoking it.
The second part of the assert is the assertion itself:

```
// excerpt from flush()
 while (readyFlushTests.length > 0) {
    var test = readyFlushTests.shift();
    this.assertDeepEqual(test.actual, test.expected);
}
```
It ends up comparing two lists to each other, the `actual` and `expect` list.
It does a deep compare and verifies two things, that the data happened on the correct time `frame` and that the value on that frame is correct. So both lists consist of objects that looks like this:

```
{ 
  frame : [some number],
  notification : { value : [your value] }
}
```
Both these properties must be equal for the assert to be true.

Doesn't seem that bloody right?  

## Symbols

I havn't really explained what we looked at with:

```
-a-b-c
```

But it actually means something. `-` means a time frame passed. `a` is just a symbol. So it matters how many `-` you write in actual and expected cause they need to match. Let's look at another test so you get the hang of it and to introduce more symbols:

```
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

```
'-x-y-z'
```
And expected pattern 
```
`---y-`
```
And this is where you clearly see that no of `-` matters. Every symbol you write be it `-` or `x` etc happens at a certain time, so in this case when `x` and `z` wont occur due to the `filter()` method it means we just replace them with `-` in the resulting output so

```
-x-y
```
becomes
```
---y
```
because `x` doesn't happen.

There are of course other symbols that are of interest that lets us define things like an error. An error is denoted as a `#` and below follows an example of such a test:

```
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

```
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








