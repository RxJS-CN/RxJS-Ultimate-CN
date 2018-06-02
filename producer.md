#Producer

A producer have the task of producing the values emitted by an Observable

```
 class Producer {
    constructor(){
      this.i = 0;
    }
 
    nextValue(){
      return this.i++;
    }
 }

```

And to use it

```
  let stream$ = Observable.create( (observer) => {
    const producer = new Producer();
    observer.next( producer.nextValue() )
    observer.next( producer.nextValue() )
  })
```    

In the [Observable Anatomy](/observable-anatomy.md) chapter there is no `Producer` in the examples but most `Observables` that are created by a helper method will have an internal `Producer` producing values that the observer emits using the `observer.next` method

