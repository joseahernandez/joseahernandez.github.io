---
layout: post
comments: true
title: Introducción a ReactiveX
---


[ReactiveX](http://reactivex.io) es una librería que nos permite crear programas asíncronos basados en eventos y que sigue el patrón [observador](https://es.wikipedia.org/wiki/Observer_%28patr%C3%B3n_de_dise%C3%B1o%29). ReactiveX utiliza objetos [Observable](http://reactivex.io/documentation/observable.html) para manejar el flujo de eventos como si fueran una colección a la cual se le pueden aplicar distintas [operaciones](http://reactivex.io/documentation/operators.html). Algunos de los beneficios que nos proporciona ReactiveX son que es una librería disponible para muchos lenguajes ([Java](https://github.com/ReactiveX/RxJava), [JavaScript]("https://github.com/Reactive-Extensions/RxJS), [.NET](https://github.com/Reactive-Extensions/Rx.NET), [Swift](https://github.com/ReactiveX/RxSwift) ...) por lo tanto se puede utilizar tanto en el lado backend como en frontend. Facilita la gestión de excepciones en la programación asíncrona, que se hace muy costosa con los típicos bloques try / catch. Además, hace más sencilla la concurrencia de los programas ya que se encarga de abstraer al programador de la capa más baja y gestiona internamente la sincronización, hilos y posibles errores de concurrencia.

Para comenzar a ver el uso de ReactiveX vamos a ver un ejemplo sencillo utilizando Java y RxJava:

``` java
String letters[] = {"a", "b", "c", "a", "d", "b", "f", "g", "a", "h", "b", "c", 
    "i", "a", "a", "j"};
Observable<String> observable = Observable.from(letters);
observable.subscribe(letter -> System.out.println(letter));
```

<!--more-->

Comenzamos declarando un array *letters* que contiene varias letras, con él, creamos un *Observable* utilizando el método [from](http://reactivex.io/documentation/operators/from.html). Este método, nos permite crear un *Observable* a partir de un array, que emitirá eventos con cada una de las componentes del array indicado. Para que el *Observable* comience a emitir estos eventos tenemos que subscribirnos a él con el método [subscribe](http://reactivex.io/documentation/operators/subscribe.html). En este ejemplo el método *subscribe* recibe una [lambda](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html) con un parámetro de entrada del mismo tipo que los eventos que se van a emitir, en este caso String y como cuerpo simplemente mostramos por pantalla el evento que se acaba de recibir. El código es bastante sencillo y su funcionalidad parece bastante clara, así que vamos a complicar un poco más las cosas añadiendo algunos operadores a este ejemplo.

Supongamos que ahora queremos mostrar por pantalla únicamente la letra *a*.

``` java
String letters[] = {"a", "b", "c", "a", "d", "b", "f", "g", "a", "h", "b", "c", 
    "i", "a", "a", "j"};
Observable<String> observable = Observable.from(letters);
observable
  .filter(letter -> letter.equals("a"))
  .subscribe(letterFiltered -> System.out.println(letterFiltered));
```

El código es exactamente el mismo que antes, pero le hemos añadido una llamada al método [filter](http://reactivex.io/documentation/operators/filter.html). *Filter*, como su nombre indica, filtra la información de los eventos que le van llegando y solo emite aquellos que cumplen la condición indicada en él. De esta forma, en esta ocasión únicamente veremos por pantalla cada vez que se emita la letra *a*.

Continuemos añadiendo más operadores al ejemplo. Ahora además de mostrar la letra *a* queremos que las letras *b* se conviertan en *a* y se muestren también por pantalla.

``` java
String letters[] = {"a", "b", "c", "a", "d", "b", "f", "g", "a", "h", "b", "c", 
    "i", "a", "a", "j"};
Observable<String> observable = Observable.from(letters);
observable
  .map(letter -> letter.equals("b") ? "a" : letter)
  .filter(letterChanged -> letterChanged.equals("a"))
  .subscribe(letterFiltered -> System.out.println(letterFiltered));
```

En este caso hemos utilizado el método [map](http://reactivex.io/documentation/operators/map.html) que le aplica una función a cada uno de los elementos, en el ejemplo, si son letras *b* las convierte en *a* y de lo contrario no realiza ninguna acción. El resto de código es exactamente igual que en los ejemplos anteriores.

Vamos a dar un pasito más y añadamos otro operador. Si en vez de imprimir cada letra por pantalla lo que queremos es contar en número de veces que llega la letra *a* podemos hacerlo de la siguiente forma:

``` java
String letters[] = {"a", "b", "c", "a", "d", "b", "f", "g", "a", "h", "b", "c", 
    "i", "a", "a", "j"};
Observable<String> observable = Observable.from(letters);
observable
  .map(letter -> letter.equals("b") ? "a" : letter)
  .filter(letterChanged -> letterChanged.equals("a"))
  .count()
  .subscribe(count -> System.out.println(count));
```

Ahora hemos añadido el método [count](http://reactivex.io/documentation/operators/count.html) que se encarga de contar el número de veces que se produce el evento, en el ejemplo será cada vez que se emita una letra *a* y una *b* que será cambiada por *a* gracias al método *map*. Finalmente se mostrará por pantalla la suma total. Como estamos viendo a partir de estos ejemplos, gracias a la variedad de [operadores](http://reactivex.io/documentation/operators.html) que nos ofrece ReactiveX podemos tratar los eventos como mejor nos convenga.

Además de lo que hemos visto hasta ahora, también podemos mezclar los eventos de dos *Observable* para procesarlos en el mismo sitio usando el método [merge](http://reactivex.io/documentation/operators/merge.html):

``` java
String letters[] = {"a", "b", "c", "a", "d", "b", "f", "g", "a", "h", "b", "c", 
    "i", "a", "a", "j"};
Integer numbers[] = { 1, 4, 5, 6, 7, 8, 1, 9, 0, 1, 2, 6, 3, 1, 4, 5, 0, 9, 4, 
    8, 5, 8 };
Observable<String> observableString = Observable.from(letters);
Observable<Integer> observableInteger = Observable.from(numbers);

Observable.merge(observableString, observableInteger)
  .subscribe(element -> System.out.println(element));
```

El resultado que nos mostrará este ejemplo son todas las letras primero y a continuación todos los números. Es decir, se procesan todos los eventos producidos por los dos observables. Creo que el uso de los *Observable* con un array queda bastante claro, así que exploremos otras funcionalidades que nos ofrece ReactiveX.

Con un *Observable* también podemos leer un fichero línea a línea y almacenarlo en un StringBuffer para cuando esté completamente leído devolverlo:

``` java
private static Observable<String> readFile() {
  return Observable.create(subscriber -> {
    BufferedInputStream bis = new BufferedInputStream(
        Thread.currentThread().getContextClassLoader()
            .getResourceAsStream("file.txt")
    );
    BufferedReader br = new BufferedReader(new InputStreamReader(bis));
    StringBuffer sb = new StringBuffer();

    subscriber.onStart();
    try {
      String line;
      while ((line = br.readLine()) != null) {
        sb.append(line);
        Thread.sleep(1);
      }
    } catch (Exception e) {
      subscriber.onError(e);
    }

    subscriber.onNext(sb.toString());
    subscriber.onCompleted();
  });
}

// Main function
System.out.println("Start process");
readFile()
  .subscribe(
    result -> System.out.println("File read"),
    error -> System.out.println("Error reading file: " + error.getMessage())
  );
System.out.println("End process");
```

Comencemos analizando el método *readFile*. Este método nos va a devolver un *Observable&lt;String&gt;* que contendrá una cadena con todo el contenido del fichero leído. Por ello, lo primero que hacemos es crearnos un Observable llamando a [Observable.create()](http://reactivex.io/documentation/operators/create.html). A este método le pasamos una lambda que recibe como parámetro de entrada un [Subscriber](http://reactivex.io/RxJava/javadoc/rx/Subscriber.html) y en el cuerpo de esta leeremos el fichero. Creamos un BufferedReader y antes de comenzar la lectura, llamamos al método [onStart](http://reactivex.io/RxJava/javadoc/rx/Subscriber.html#onStart%28%29) del Subscriber. Con esto estamos informando que el *Observable* está comenzando a realizar su trabajo. Seguidamente leemos el fichero línea a línea y lo almacenamos en un StringBuffer. He añadido un sleep para simular un retardo en la lectura. Si ocurre algún error, llamamos al método [onError](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onError%28java.lang.Throwable%29) pasándole el error que ha ocurrido y si de lo contrario no ocurre ningún error, al finalizar la lectura llamamos a [onNext](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onNext%28T%29) pasando el contenido leído, lo cual producirá un evento de nuestro *Observable,* y finalizamos llamando a [onCompleted](http://reactivex.io/RxJava/javadoc/rx/Observer.html#onCompleted%28%29). Esta última llamada indicará que nuestro *Observable* ha finalizado su trabajo.

Si ahora miramos desde donde llamamos a esta función,  vemos que nuestro método *subscribe* tiene dos lambdas. La primera de ella se ejecutará cuando dentro del método *readFile* se llama a *onNext,* es decir, se produce un evento,  en su parámetro tendrá el valor indicado cuando se invocó a esta función. Por su parte, la segunda lambda se ejecutará en caso de ocurrir algún error dentro de *readFile* y haber llamado a *onError*.

Ejecutando este ejemplo podemos ver como se muestra por pantalla las frases "Start process", cuando finaliza la lectura del fichero se muestra  "File read" y para finalizar "End process". Si nos damos cuenta todo esto se ha ejecutado secuencialmente, mientras estabamos leyendo el fichero, hemos tenido el hilo principal bloqueado sin poder realizar ninguna otra operación. Esto lo podemos mejorar haciendo que la lectura se realize asíncronamente en otro hilo, para ello vamos a modificar el ejemplo.

El método *readFile* lo dejamos tal y como está, pero vamos a modificar la forma de llamarlo y lo actualizaremos de la siguiente manera:

``` java
System.out.println("Start process");
CountDownLatch countDown = new CountDownLatch(1);

readFile()
  .subscribeOn(Schedulers.computation())
  .subscribe(
    result -> System.out.println("File read"),
    error -> System.out.println("Error reading file: " + error.getMessage()),
    () -> countDown.countDown()
  );
System.out.println("End process");
countDown.await();
```

Lo primero que nos puede llamar la atención es el uso del [CountDownLatch](http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/CountDownLatch.html). Esto es una herramienta de sincronización ya que no quiero que el hilo principal finalice y cierre el proceso hasta que no se termine de leer el fichero, por eso lo inicializo a uno y al final del método main llamo al método *await* para que se quede esperando hasta que su contador esté a 0. Además del CountDownLatch, también hemos llamado al método [subscribeOn](http://reactivex.io/documentation/operators/subscribeon.html). Con este método estamos indicando que queremos que el contenido de la función *readFile* se ejecute en un planificador (Scheduler) distinto al hilo principal, en este caso hemos indicado un planificador para realizar cálculos. Además de esto, nuestra llamada a *subscribe* tiene una tercera lambda, la cual no tiene parámetros de entrada y se ejecutará cuando desde el *Observable* se llame al método *onCompleted*. Lo que hacemos en esta lambda es descontar uno al *CountDownLatch,* de forma que como ya hemos terminado de procesar el *Observable*, se libera el semáforo y puede finalizar el proceso.

Al ejecutar este ejemplo podemos ver por pantalla las frases "Start process", a continuación "End process" y cuando se finaliza la lectura del fichero "File read". De esta forma hemos ejecutado la lectura del fichero en otro hilo sin la necesidad de bloquear el hilo principal. Como hemos visto, es muy sencillo realizar programación asíncrona con ReactiveX.

Otra forma de realizar el mismo proceso, podría ser emitiendo un evento con cada línea del fichero que se lea y guardando el StringBuffer dentro de la función principal:

``` java
private static Observable<String> readFile() {
  return Observable.create(subscriber -> {
    BufferedInputStream bis = new BufferedInputStream(
        Thread.currentThread().getContextClassLoader()
            .getResourceAsStream("file.txt")
    );
    BufferedReader br = new BufferedReader(new InputStreamReader(bis));

    subscriber.onStart();
    try {
      String line;
      while ((line = br.readLine()) != null) {
        subscriber.onNext(line);
        Thread.sleep(1);
      }
    } catch (Exception e) {
      subscriber.onError(e);
    }

    subscriber.onCompleted();
  });
}

// Main function
System.out.println("Start process");
CountDownLatch countDown = new CountDownLatch(1);

StringBuffer buffer = new StringBuffer();

readFile()
  .subscribeOn(Schedulers.computation())
  .subscribe(
    result -> {
      buffer.append(result);
      System.out.println("Line read");
    },
    error -> System.out.println("Error reading file: " + error.getMessage()),
    () -> {
      System.out.println("File read with content: " + buffer.toString());
      countDown.countDown();
    }
  );
System.out.println("End process");
countDown.await();
```

Para ello simplemente tendríamos que llamar al método *onNext* con cada línea y en la primera lambda del *subscribe* almacenar el evento en el StringBuffer. Finalmente en la última lambda que le pasamos se mostraría por pantalla todo el contenido leído.

Sigamos viendo más ejemplos, a continuación vamos a ver como usar [interval](http://reactivex.io/documentation/operators/interval.html) para producir eventos cada x tiempo:

``` java
CountDownLatch countDownLatch = new CountDownLatch(1);
Observable.interval(1, TimeUnit.SECONDS)
  .subscribe(timer -> {
    System.out.println("Tick " + timer);
    if (timer == 5) {
      countDownLatch.countDown();
    }
  });

System.out.println("End");
countDownLatch.await();
```

Los intervalos se ejecutan en un hilo distinto al principal por defecto, por lo tanto volveremos a utilizar el CountDownLatch para detener el hilo principal y no finalizar la aplicación hasta ejecutar el intervalo 5 veces. Para crear el *interval* utilizamos dos parámetros, el primero es cada cuando tiempo se va a generar y el segundo es la unidad. En este caso tenemos un evento cada segundo. El *subscribe* del ejemplo creo que no tiene ningún misterio así que no necesito entrar en detalle.

Otra cosa que merece la pena explicar es que hay dos tipos de *Observable*: *Hot* y *Cold*. Los *Cold Observable* son aquellos que no emiten ningún evento si no hay nadie subscrito a ellos, mientras que los *Hot Observable* son los que emiten eventos aunque no tengan a nadie subscrito. Todos los que hemos visto en los anteriores ejemplos son *Cold Observable *así que ahora vamos a ver un ejemplo de Hot.

``` java
CountDownLatch countDownLatch = new CountDownLatch(1);
Observable<Long> observable = Observable.interval(1, TimeUnit.SECONDS);

PublishSubject<Long> publishSubject = PublishSubject.create();
observable.subscribe(publishSubject);

Thread.sleep(4000);

publishSubject
  .subscribe(timer -> {
    System.out.println("Tick " + timer);
    if (timer == 5) {
      countDownLatch.countDown();
    }
  });

System.out.println("End");
countDownLatch.await();
```

Volvemos a crear un *Observable* que lanza un evento cada segundo, pero en esa ocasión creamos un [PublishSubject](http://reactivex.io/RxJava/javadoc/rx/subjects/PublishSubject.html) al que subscribimos al *Observable*. Con esto conseguimos que el *Observable* comience a emitir eventos. A continuación suspendemos el hilo durante 4 segundos y después nos subscribimos al PublishSubject. En ese momento comenzaremos a recibir eventos y los escribiremos por pantalla. Como es de esperar, si se comienzan a emitir eventos y estamos 4 segundos en el sleep, al subscribirnos únicamente llegaran los eventos 4 y 5 (el primer evento es el 0).

Otra forma de crear *Hot Observables* es con la utilización de[ConnectableObservable](http://reactivex.io/RxJava/javadoc/rx/observables/ConnectableObservable.html) como se muestra en el siguiente ejemplo:

``` java
CountDownLatch countDownLatch = new CountDownLatch(1);
ConnectableObservable<Long> connectableObservable = 
    Observable.interval(1, TimeUnit.SECONDS).publish();

connectableObservable.connect();

Thread.sleep(4000);

connectableObservable
  .subscribe(timer -> {
    System.out.println("Tick " + timer);
    if (timer == 5) {
      countDownLatch.countDown();
    }
  });

System.out.println("End");
countDownLatch.await();
```

Vemos que al crear el *Observable* llamamos al método *publish* que nos devuelve un *ConnectableObservable*. A continuación, llamamos al método [connect](http://reactivex.io/documentation/operators/connect.html) de este para que se comiencen a emitir los eventos. Finalmente como en el ejemplo anterior, esperamos 4 segundos y nos subscribimos. El resultado es el mismo que el anterior, al esperar 4 segundos y subscribirnos únicamente recibiremos los eventos 4 y 5.

Para finalizar vamos a ver un ejemplo de como hacer una llamada http asíncrona utilizando observables:

``` java
private static Observable<String> getResponse(String endpoint) {
  return Observable.create(subscriber -> {
    subscriber.onStart();

    try {
      URL url = new URL(endpoint);
      URLConnection connection = url.openConnection();
      StringBuffer sb = new StringBuffer();

      BufferedReader br = new BufferedReader(
        new InputStreamReader(connection.getInputStream())
      );
      String line;
      while ((line = br.readLine()) != null) {
        sb.append(line);
      }
      br.close();

      Thread.sleep(1000);

      subscriber.onNext(sb.toString());
      subscriber.onCompleted();
    } catch (Exception e) {
      subscriber.onError(e);
    }
  });
}

// Main function
CountDownLatch countDownLatch = new CountDownLatch(1);
getResponse("http://google.com")
  .subscribeOn(Schedulers.io())
  .subscribe(
    response -> System.out.println(response),
    error -> System.out.println("Error: " + error.getMessage()),
    () -> countDownLatch.countDown()
  );

do {
  System.out.println("Doing some work");
  Thread.sleep(500);
} while (countDownLatch.getCount() == 1);
```


El método *getResponse* recibe un endpoint al que nos conectaremos y del que leeremos su respuesta. Para ello, lo primero que haremos será crear un *Observable* que nos devuelva un String con todo el contenido de la página. A continuación, inicializamos la URL, abrimos la conexión, leemos la entrada y la vamos almacenando en un StringBuffer (al igual que hicimos en el ejemplo de leer de un fichero). Cuando hemos leído la respuesta por completo, llamamos a *onNext* pasándole el resultado y a *onComplete*. Hay que mencionar que he añadido un sleep para simular un retardo en la respuesta.

Por su parte, desde el código donde llamamos al método *getResponse*, llamamos a *subscribeOn* para ejecutarlo en un planificador distinto (de entrada y salida en este caso io) y cuando obtenemos la respuesta la mostramos por pantalla. Mientras tanto en el hilo principal seguimos ejecutando código, en este caso mostrando por pantalla la cadena "Doing some work". La conclusión que podemos sacar de esto es que mientras se está ejecutando la llamada http asíncronamente, en el hilo principal podemos seguir haciendo cosas como por ejemplo seguir escuchando más llamadas para hacer nuevas peticiones.

Hasta aquí ha llegado esta introducción a ReactiveX, espero que haya ayudado a entender un poco más esta librería y a mostrar ejemplos de como llegar a utilizarla. He publicado todo el código que he usado en los ejemplos en [Github](https://github.com/joseahernandez/rxjava-sample) para poderlo ejecutar y ver con más detalle cada uno de ellos.