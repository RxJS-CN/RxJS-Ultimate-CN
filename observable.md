# Observable vs Promise
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
      resolve( [1,2,3] )
   })

})

promise.then((value) => {
  console.log('Value',data)
})
```


Promises lack the ability to generate more than one value, ability to retry and it doesn't really play well with other async concepts.

