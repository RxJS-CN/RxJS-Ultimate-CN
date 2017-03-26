# Understanding it all
So there are `Observables` `Producer`, `Observer` and everything plays together. To help you further understand Andre Staltz, the creator of CycleJs as well as core contributor of Rxjs just released a github repo to help further in our understanding of how everything plays together [Toy Rxjs](https://github.com/staltz/toy-rx)

All possible credit to Andre Staltz @andrestaltz


**Possible Substriction impl**
```
class Subscription {
  constructor(unsubscribe) {
    this.unsubscribe = unsubscribe;
  }
}
```

**Possible Subscriber impl**
```
class Subscriber extends Subscription {
  constructor(observer) {
    super(function unsubscribe() {});
    this.observer = observer;
  }

  next(x) {
    this.observer.next(x);
  }

  error(e) {
    this.observer.error(e);
    this.unsubscribe();
  }

  complete() {
    this.observer.complete();
    this.unsubscribe();
  }
}
```
**Possible Observable impl**
```
class Observable {
  subscriber; 

  constructor(subscribe) {
    this.subscribe = subscribe;
  }

  static create(subscribe) {
    return new Observable(function internalSubscribe(observer) {
      this.subscriber = new Subscriber(observer);
      const subscription = new Subscription(subscriber);
      subscriber.unsubscribe = subscription.unsubscribe.bind(subscription);
      return subscription;
    });
  }
  
  unsubscribe() {
     this.
  }
}
```
What happens here in the `create()` is really interesting. We instantiate a `subscriber` and we also create a `subscription` which `subscription.` is our cleanup function, remember this code:

 ```
 Rx.Observable.create(observer => {
     let interval = setInterval(() => {
        observer.next( 1 )
     })
     
     return function cleanup(){
       clearInterval( interval )
     }
 })
 ``` 
 That 


**Possible Subject impl**
```
class Subject extends Observable {
  constructor() {
    super(function subscribe(observer) {
      this.observers.push(observer);
      return new Subscription(() => {
        const index = this.observers.indexOf(observer);
        if (index >= 0) this.observers.splice(index, 1);
      });
    });
    this.observers = [];
  }

  next(x) {
    this.observers.forEach((observer) => observer.next(x));
  }

  error(e) {
    this.observers.forEach((observer) => observer.error(e));
  }

  complete() {
    this.observers.forEach((observer) => observer.complete());
  }
}
```