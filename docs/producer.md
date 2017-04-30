# Producer (生产者)

Producer 的任务是生产 Observable 所发出的值。

```javascript
class Producer {
   constructor(){
     this.i = 0;
   }

   nextValue(){
     return i++;
   }
}
```

使用 Producer

```javascript
let stream$ = Rx.Observable.create( (observer) => {
   observer.next( Producer.nextValue() )
   observer.next( Producer.nextValue() )
})
```

在 [Observable Anatomy](observable-anatomy.md) 章节中并没有在示例中使用 `Producer`，大多数 `Observables` 都是通过辅助方法创建的，在这些方法中会有内部的 `Producer` 来生产值，这些值通过 observer 的 `observer.next` 方法发出
