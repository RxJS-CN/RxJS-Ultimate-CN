# Observable 包装

在 [Observable 剖析](observable-anatomy.md)章节中我们只学到了关键操作符 `next()`、`error()` 和 `complete()`，如果是我们自己定义的 Observable 的话，可以使用这些方法来驱动 Observable 。我们还学到了，这些方法会触发相应的回调函数。

用 Observable 包装意味着接收一些非 Observable 的东西并将其转换为 Observable，这样就可以很好的与其它 Observable 配合使用。同样还意味着现在我们可以使用[操作符](operators.md)了。

## 包装 ajax 调用

```javascript
let stream = Rx.Observable.create((observer) => {
   let request = new XMLHttpRequest();

   request.open( ‘GET’, ‘url’ );
   request.onload =() =>{
      if(request.status === 200) {
         observer.next( request.response );
         observer.complete();
     } else {
          observer.error('error happened');
     }
   }

   request.onerror = () => {  
       observer.error('error happened')
   }
   request.send();
})

stream.subscribe(
   (data) => console.log( data )  
)
```
这里我们需要做的三件事：`发出数据`、`异常处理`和`关闭流`

### 发出数据

```javascript
if(request.status === 200) {
  observer.next( request.response )  // 发出数据

}
```

### 处理潜在的异常

```javascript
else {
   observer.error('error happened');
}
```

### 关闭流

```javascript
if(request.status === 200) {
  observer.next( request.response )
  observer.complete()  // 关闭流，因为我们不想要更多的数据了
}
```

## 包装语音音频 API

```javascript
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

### 语音识别流

这将激活浏览器的麦克风并记录我们的语音

```javascript
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

这段代码建立了语音识别 API，然后等待响应，并在响应一次后完成流，很像第一个使用 AJAX 的示例。

注意还定义一个函数用来清理

```javascript
return () => {
   speech.stop();
 }
```

所以我们可以通过调用 `speechRecognition.unsubscribe()` 来清理系统资源

### Speech synthesis utterance, say

This is responsible for uttering what you want it to utter ( say ).

```javascript
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

```javascript
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

Logic should be read as follows `heyClick$` is activated on a click on a button. `speechRecognition` is listening for what we say and sends that result into `heyClick$` where the switching logic determines an appropriate response that is uttered by `say` Observable.

all credit due to @ladyleet and @benlesh

## Summary

One easier Ajax wrapping and one a little more advanced Speech API has been wrapped into an Observable. The mechanics are still the same though: 1) where data is emitted, add a call to `next() `2) if there is NO more data to emit call `complete` 3) if there is a need for it, define a function that can be called upon `unsubscribe()` 4) Handle errors through calling `.error()` in the appropriate place. (only done in the first example)
