#Observable wrapping 
We have just learned in [Observable Anatomy](/observable-anatomy.md) that the key operators `next()` , `error()` and `complete` is what makes our Observable tick, if we define it ourselves. We have also learned that these methods triggers a corresponding callback on our subscription. 

Wrapping something in an observable means we take something that is NOT an Observable and turn it into one, so it can play nice with other Observables. It also means that it can now use [Operators](/operators.md).

## Wrapping an ajax call 
```
let stream = Rx.Observable.create((observer) => {
   let request = new XMLHttpRequest();

   request.open( ‘GET’, ‘url’ );
   request.onload =() =>{
      if(request.status === 200) {
         observer.next( request.response )
         observer.complete
     } else {
          observer.error('error happened');
     }
   }
   
   request.onerror = () => {  
       observer.error('error happened')                                                                                } 
   request.send();
})

stream.subscribe(
   (data) => console.log( data )  
)
```

Three things we need to do here `emit data`, `handle errors` and `close the stream`
### Emit the data

```
if(request.status === 200) {
  observer.next( request.response )  // emit data

}
```
### Handle potential errors

```
else {
       observer.error('error happened');
  }
```
and
```
request.onerror = () => {
   observer.error('error happened') 
} 
```

### Close the stream
```
if(request.status === 200) {
  observer.next( request.response )
  observer.complete()  // close stream, as we don't expect more data
}
```


## Wrapping a speech audio API
```
console.clear();


const { Observable } = Rx;

const speechRecognition$ = new Observable(observer => {
   const speech = new webkitSpeechRecognition();

   speech.onresult = (event) => {
     observer.next(event);
     observer.complete();
   };

   speech.start();
  
   return () => {
     speech.stop();
   }
});

const say = (text) => new Observable(observer => {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.onend = (e) => {
    observer.next(e);
    observer.complete();
  };
  speechSynthesis.speak(utterance);
});


const button = document.querySelector("button");

const heyClick$ = Observable.fromEvent(button, 'click');

heyClick$
  .switchMap(e => speechRecognition$)
  .map(e => e.results[0][0].transcript)
  .map(text => {
    switch (text) {
      case 'I want':
        return 'candy';
      case 'hi':
      case 'ice ice':
        return 'baby';
      case 'hello':
        return 'Is it me you are looking for';
      case 'make me a sandwich':
      case 'get me a sandwich':
        return 'do it yo damn self';
      case 'why are you being so sexist':
        return 'you made me that way';
      default:
        return `I don't understand: "${text}"`;
    }
  })
  .concatMap(say)
  .subscribe(e => console.log(e));

```
### Speech recognition stream
This activates the microphone in the browser and records us

```
const speechRecognition$ = new Observable(observer => {
   const speech = new webkitSpeechRecognition();

   speech.onresult = (event) => {
     observer.next(event);
     observer.complete();
   };

   speech.start();
  
   return () => {
     speech.stop();
   }
});

```

This essentially sets up the speech recognition API. We wait for one response and after that we complete the stream, much like the first example with AJAX.

Note also that a function is defined for cleanup
```
return () => {
   speech.stop();
 }
```
so that we can call `speechRecognition.unsubscribe()` to clean up resources

### Speech synthesis utterance, say
This is responsible for uttering what you want it to utter ( say ). 

```
const say = (text) => new Observable(observer => {
  const utterance = new SpeechSynthesisUtterance(text);
  utterance.onend = (e) => {
    observer.next(e);
    observer.complete();
  };
  speechSynthesis.speak(utterance);
});

```

### main stream hey$
```
heyClick$
  .switchMap(e => speechRecognition$)
  .map(e => e.results[0][0].transcript)
  .map(text => {
    switch (text) {
      case 'I want':
        return 'candy';
      case 'hi':
      case 'ice ice':
        return 'baby';
      case 'hello':
        return 'Is it me you are looking for';
      case 'make me a sandwich':
      case 'get me a sandwich':
        return 'do it yo damn self';
      case 'why are you being so sexist':
        return 'you made me that way';
      default:
        return `I don't understand: "${text}"`;
    }
  })
  .concatMap(say)
  .subscribe(e => console.log(e));

```
Logic should be read as follows
`heyClick$` is activated on a click on a button.
`speechRecognition` is listening for what we say and sends that result into `heyClick$` where the switching logic determines an appropriate response that is uttered by `say` Observable.

all credit due to @ladyleet and @benlesh

## Summary
One easier Ajax wrapping and one a little more advanced Speech API has been wrapped into an Observable. The mechanics are still the same though:
1) where data is emitted, add a call to `next()`
2) if there is NO more data to emit call `complete`
3) if there is a need for it, define a function that can be called upon `unsubscribe()` 
4) Handle errors through calling `.error()` in the appropriate place. (only done in the first example)