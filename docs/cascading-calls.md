# 级联调用

级联调用意味着调用A执行后，调用B会基于A执行，调用C又会基于调用B执行，以此类推。

## 依赖调用

依赖调用意味着调用需要按顺序执行。调用2必须在调用1返回后执行。甚至可能调用2需要使用调用1返回的数据。

想象下以下场景：

* 用户需要先登录
* 然后可以获取用户详情
* 再然后可以获取用户订单

### Promise 方式

```javascript
login()
     .then(getUserDetails)
     .then(getOrdersByUser)
```

### RxJS 方式

```javascript
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

// 订单数组
```

I've simplied this one a bit in the Rxjs example but imagine instead of

```javascript
Rx.Observable.of()
```

it does the proper `ajax()` call like in [Operators and Ajax](operators-and-ajax.md)

## Semi dependant

* We can fetch a users details
* Then we can fetch Orders and Messages in parallell.

### Promise approach

```javascript
getUser()
   .then((user) => {
      return Promise.all(
        getOrders(),
        getMessages()
      )
   })
```

### Rxjs approach

```javascript
let stream$ = Rx.Observable.of({ id : 1, name : 'User' })
stream.switchMap((user) => {
  return Rx.Observable.forkJoin(
     Rx.Observable.from([{ id : 114, user: 1}, { id : 115, user: 1}]),
     Rx.Observable.from([{ id : 200, user: 1}, { id : 201, user: 1}])
  )
})

stream$.subscribe((result) => {
  console.log('Orders', result[0]);
  console.log('Messages', result[1]);

})
```

## GOTCHAS

We are doing `switchMap()` instead of `flatMap()` so we can abandon an ajax call if necessary, this will make more sense in [Auto complete recipe](recipes-auto-complete.md)
