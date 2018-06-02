Let's dive right in. We have created something called an Observable. An async construct, much like a promise that we can listen to once the data arrives.

```
let stream$ = Rx.Observable.from([1,2,3])

stream$.subscribe( (value) => {
   console.log('Value',value);
})

// 1,2,3
```

The corresponding way of doing this if dealing with promises would be to write

```
let promise = new Promise((resolve, reject) => {
   setTimeout(()=> {
      reject( [1,2,3] )
   })

})

promise.then((value) => {
  console.log('Value',value)
})
```

Ok, so that's pretty clear but why would we need an additional async construct? I like promises how they work, they are simple.

> Mm, yes but there is more to it than that

Promises lack the ability to generate more than one value, ability to retry and it doesn't really play well with other async concepts.

