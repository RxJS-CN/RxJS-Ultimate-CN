# Cascading calls

A cascading call means that based on what call is happening another call should take place and possibly another one based on that.

## Dependant calls

A dependant call means the calls needs to happen in order. Call 2 must happen after Call 1 has returned. It might even be possible that Call2 needs be specified using data from Call 1.

Imagine you have the following scenario:

* A user needs to login first
* Then we can fetch their user details
* Then we can fetch their orders

### Promise approach

```
login()
     .then(getUserDetails)
     .then(getOrdersByUser)
```

### Rxjs approach

```
let stream$ = Rx.Observable.of({ message : 'Logged in' })
      .switchMap( result => {
         return Rx.Observable.of({ id: 1, name : 'user' })
      })
      .switchMap((user) => {
        return Rx.Observable.from(
           [ { id: 114, userId : 1 },
             { id: 117, userId : 1 }  ])
      })

stream$.subscribe((orders) => {
  console.log('Orders', orders);
})

// Array of orders
```

I've simplied this one a bit in the Rxjs example but imagine instead of

```
Rx.Observable.of()
```

it does the proper `ajax()` call like in [Operators and Ajax](/operators-and-ajax.md)

## Semi dependant

* We can fetch a users details
* Then we can fetch Orders and Messages in parallell.

### Promise approach

```
getUser()
   .then((user) => {
      return Promise.all(
        getOrders(),
        getMessages()
      )
   })
```

### Rxjs approach

```
let stream$ = Rx.Observable.of({ id : 1, name : 'User' })
stream.switchMap((user) => {
  return Rx.Observable.forkJoin(
     Rx.Observable.from([{ id : 114, user: 1}, { id : 115, user: 1}],
     Rx.Observable.from([{ id : 200, user: 1}, { id : 201, user: 1}])
  )
})

stream$.subscribe((result) => {
  console.log('Orders', result[0]);
  console.log('Messages', result[1]);

})
```

## GOTCHAS

We are doing `switchMap()` instead of `flatMap()` so we can abandon an ajax call if necessary, this will make more sense in [Auto complete recipe](/recipes.md)

