# Observer

Note the following code example creating an `Observable`
```
let stream$ = Rx.Observables.create((observer) => {
  observer.next(4);
})
```

`create` method takes a function with an input parameter `observer`.

An Observer is just an object with the following methods `next` `error` `complete`

```
observer.next(1);
observer.error('some error')
observer.complete();
```