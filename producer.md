#Producer

A producer have the task of producing the values emitted by an Observable

    let stream$ = Rx.Observable.create( (observer) => {
       observer.next( Producer.nextValue() )
       observer.next( Producer.nextValue() )
    })
    

In the [Observable Anatomy](/observable-anatomy.md) chapter there is no `Producer` in the examples but most `Observables` that are created by a helper method will have an internal `Producer` producing values that the observer emits using the `observer.next` method
 