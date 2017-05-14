# Operators and Ajax

There is an `ajax` operator on the Rx object.

## Using the ajax() operator

index.html

```html
<html>
    <body>
        <div id="result">

        </div>
        <script src="https://unpkg.com/@reactivex/rxjs@5.0.1/dist/global/Rx.js"></script>
        <script src="app.js"></script>
    </body>
</html>
```

app.js

```javascript
let person$ = Rx.Observable
  .ajax({
      url : 'http://swapi.co/api/people/1',
      crossDomain: true,
      createXHR: function () {
        return new XMLHttpRequest();
     }
    })
  .map(e => e.response);

const subscription = person$
  .subscribe(res => {
      let element = document.getElementById('result');
      element.innerHTML = res.name
      console.log(res)
  });
```

A little GOTCHA from this is how we call the `ajax()` operator, we obviously specify a bunch of stuff other thant the `url` property. The reason for this is that the `ajax` operator does the following :

> default factory of XHR in ajaxObservable sets withCredentials to true by default

So we give at a custom factory and it works. I understand this is an issue that is currently looked upon

## Using fetch API

```javascript
const fetchSubscription = Rx.Observable
.from(fetch('http://swapi.co/api/people/1'))
.flatMap((res) => Rx.Observable.from(res.json()) )
.subscribe((fetchRes) => {
    console.log('fetch sub', fetchRes);
})
```

So a couple of things here happens worth mentioning

* fetch api is promised base, however using `.from()` Rxjs allows us to insert promise as a parameter and converts it to an Observable.
* BUT the result coming back is a response object that we need to convert to Json. Calling `json()` will do that for you but that operation returns a Promise. So we need to use another `from()` operator. But creating an Observable inside an observable creates a list of observables and we can't have that, we want Json. So we use an operator called `flatMap()` to fix that. Read more on `flatMap()` [here](operators-observable-in-an-observable.md)

And finally we get the Json we expect, no issues with CORS but a little more to write.
