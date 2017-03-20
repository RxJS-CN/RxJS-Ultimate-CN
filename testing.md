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
   

