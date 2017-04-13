---
layout: post
comments: true
title: Vert.x Web I
---

Como vimos en la entrada sobre [Vert.x](http://josehernandez.xyz/2017/01/28/vertx.html), este toolkit nos permite crear aplicaciones reactivas de una forma muy sencilla. En esta ocasión vamos a hablar de **Vert.x Web** que es un componente que nos proporciona un conjunto de funcionalidad para crear aplicaciones web.

En esta serie de entradas sobre Vert.x Web veremos todo el amplio abanico de opciones que nos ofrece este toolkit para crear una aplicación web. Comenzaremos por lo más básico para luego ir añadiendo características más avanzadas.

## Primeros pasos

Vert.x Web nos permite crear cualquier tipo de aplicación web que queramos, aplicaciones clásicas en el lado servidor, aplicaciones RESTfull e incluso aplicaciones en tiempo real (con [server push](https://en.wikipedia.org/wiki/Push_technology)). No importa que es lo que queramos crear, Vert.x nos proporciona las herramientas para que desarrollemos cualquier aplicación web que tengamos en mente.

Para crear un proyecto con Vert.x Web hay que añadir su dependencia. Si usamos [Gradle](https://gradle.org) añadiremos en el fichero *build.gradle* la siguiente dependencia:

```none
dependencies {
  compile 'io.vertx:vertx-web:3.4.1'
}
```

Si usamos [Maven](https://maven.apache.org) añadiremos en el fichero *pom.xml* la dependencia:
 
```none
...
  <dependency>
    <groupId>io.vertx</groupId>
    <artifactId>vertx-web</artifactId>
    <version>3.4.1</version>
  </dependency>
...
```
<!--more-->
## Definir rutas

Uno de los componentes core de Vert.x Web es el [Route](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html). Este componente se encarga de tener registradas las rutas a las que nuestra aplicación va a responder, para cuando reciba una petición sobre una de ellas llamar a su manejado asociado. 

```java
HttpServer server = vertx.createHttpServer();
Router router = Router.router(vertx);

router.route("/hello")
    .handler(routingContext -> {
        HttpServerResponse response = routingContext.response();
        response.putHeader("content-type", "text/plain");

        response.end("Hello World!");
    });

server.requestHandler(route::accept).listen(8080);
```

En el ejemplo anterior podemos ver como en el router se ha registrado la ruta */path* y en su manejador *(handler)*, que recibe un objeto del tipo [RoutingContext](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html), le añadimos una cabecera y respondemos al cliente con el mensaje *Hello World!*. Importante la llamada a *end* para que la respuesta se envíe al cliente. Finalmente en el server indicamos que el manejo de las peticiones se llevará a cabo mediante el route y lo ponemos a escuchar en el puerto 8080.

Cuando vamos a definir las rutas para nuestra aplicación, Vert.x nos ofrece muchas posibilidades para que las personalicemos a nuestro gusto. Las más comunes son las *rutas exactas*:

```java
router.route("/user/profile")
    .handler( ... );
```
Con este ejemplo, cuando la ruta que se reciba sea /user/profile se ejecutará el handler indicado. Hay que mencionar que las barras del final de las rutas son ignoradas, lo que significa que las siguientes rutas /user/profile/ y /user/profile// son equivalentes a la anterior, pero /users/profile/edit no es igual.

Otra posibilidad son definir *rutas que comienzan igual pero difieren en la parte final*. Si queremos que todas las rutas con un mismo comienzo sean manejadas por el mismo handler esta es la solución más cómoda. Para definir estas rutas se usa el símbolo \* de forma que un ruta como la siguente:

```java
router.route("/user/profile/*")
    .handler( ... );
```
Escucharía todas las peticiones que comenzarán por ella como: /user/profile, /user/profile/edit, /user/profile/me/photo.jpg ... y todas ellas serían manejadas por el mismo handler.

La última opción que nos deja Vert.x para definir rutas, es usar expresiones regulares:

```java
route.route().pathRegex(".*profile")
    .handler(...);

// Otra opción

route.routeWithRegex(".*profile")
    .handler(...);
```
En los dos ejemplos anteriores se ejecutaría el manejado para todas las rutas que contengan profile: /users/profile, /profile, /users/profile/me ... Cualquier expresión regular nos valdría para indicar una ruta.

Las rutas definidas, pueden contener parámetros que nos interese obtener en el handler. Para ello indicaremos estos parámetros en las rutas anteponiendo al nombre del parámetro el símbolo ":" Posteriormente dentro del handler podemos acceder a ellos obteniendo el objeto [HttpServerRequest](http://vertx.io/docs/apidocs/io/vertx/core/http/HttpServerRequest.html) desde el routingContext y llamando al método *getParam()*:

```java
router.route("/user/:userId")
    .handler(routingContext -> {
        String userId = routingContext.request().getParam("userId");
        ...
});
```
En el caso de rutas con expresiones regulares, también podemos capturar los parámetros, aunque no es tan sencillo ya que hay que usar los grupos de captura.

```java
router.routeWithRegex(".*profile")
    .pathRegex("\\/([^\\/]+)\\/([^\\/]+)")
    .handler(routingContext -> {
        String first = routingContext.request().getParam("param0");
        String second = routingContext.request().getParam("param1");
        ...
    });
```
En el ejemplo anterior se está capturando dos parámetros que vienen separados por el carácter /. Es decir, en la ruta /user/profile tendremos en *param0* user y en *param1* profile. A partir de aquí podemos complicar la expresión regular tanto como queramos y utilizar distintos grupos de captura para recoger los valores que nos interese.

## Rutas con métodos HTTP

Hasta ahora hemos visto como registrar rutas para nuestra aplicación, pero el protocolo HTTP proporciona una serie de métodos para poder hacer distintos tipos de peticiones GET, POST, PUT, DELETE... Con Vert.x podemos indicar cada una de nuestras rutas a que tipo de método responde

```java
router.route(HttpMethod.POST, "/user")
    .handler(...);
```
En el ejemplo anterior únicamente se responderá a la ruta /user si el método HTTP con el que se ha llamado es POST. Otra forma de hacer esto mismo es usando directamente los métodos de router [get](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#get-java.lang.String-), [getWithRegex](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#getWithRegex-java.lang.String-), [post](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#post-java.lang.String-), [postWithRegex](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#postWithRegex-java.lang.String-), [put](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#put-java.lang.String-), [putWithRegex](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#putWithRegex-java.lang.String-)...

```java
router.post("/user/")
    .handler(...);
```
Además podemos combinar varias rutas para con un mismo handler responder a ellas:

```java
router.route()
    .method(HttpMethod.POST)
    .method(HttpMethod.PUT)
    .handler(...);
```

## Orden de las rutas

Por defecto las rutas se van resolviendo por el orden en el que han sido agregadas al Router. Una vez se encuentra una coincidencia se ejecuta el handler asociado y no se siguen buscando coincidencias a excepción que se llame al método [next](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#next--), en cuyo caso se seguirá buscando coincidencias. Si queremos añadir datos de respuesta durante todas las coincidencias, tendremos que activar la respuesta por trozos (chunked):

```java
router.route("/user/profile")
    .handler(routingContext -> {
        HttpServerResponse response = routingContext.response();
        response.setChunked(true);

        response.write("Response1 - ");

        routingContext.next();
    });

router.route("/user/profile")
    .handler(routingContext -> {
        HttpServerResponse response = routingContext.response();
        response.write("Response2").end();
    });
```
La respuesta a la llamada /user/profile con el ejemplo anterior devolverá *Response1 - Response2*. Primero se ejecutará el primer handler y a continuación gracias a la llamada a next se ejecutará el segundo handler.

En caso de que queramos modificar el orden de resolución de las rutas, podemos utilizar el método [order](http://vertx.io/docs/apidocs/io/vertx/ext/web/Route.html#order-int-) para modificar su posición a la hora de buscar coincidencias. La primera ruta que se añade tiene el orden 0, la segunda el 1 y así sucesivamente. En caso que quisiéramos invertir el orden podríamos hacer lo siguiente:

```java
router.route("/user/profile")
    .handler(routingContext -> {
        ...
        routingContext.next();
    });

router.route("/user/profile")
    .handler(routingContext -> {
        ...
    })
    .order(-1);
```

Al indicarle un -1 al orden de la segunda ruta, está se resolverá primero ya que su posición es -1, mientras que la primera ruta que añadimos tiene la posición 0.

Si quisiéramos mantener algún tipo de dato entre los distintos handlers y únicamente durante el tiempo de vida de la petición podríamos usar el RoutingContext para ello:

```java
router.route("/user/profile")
    .handler(routingContext -> {
        routingContext.put("info", "Hello");
        routingContext.next();
    });

router.route("/user/profile")
    .handler(routingContext -> {
        String data = routingContext.get("info");
        routingContext.response().end(data + " World!");
    })
```
En el primer manejador se almacenaría la cadena *Hello* con la clave *info*, posteriormente en el segundo, se extraería esa cadena y se concatenaría con la cadena *World!* para devolverla al usuario. Después de esto se limpiaría el RoutingContext y la clave *info* no existiría en la siguiente petición.


## Rutas con tipo MIME

Además de los visto hasta ahora, también podemos definir rutas basadas en el tipo [MIME](https://es.wikipedia.org/wiki/Multipurpose_Internet_Mail_Extensions) que se envía en la petición desde el cliente.

```java
router.route("/user/profile")
    .consumes("text/html")
    .handler( ... );
```

En el ejemplo anterior hemos usado [consumes](http://vertx.io/docs/apidocs/io/vertx/ext/web/Route.html#consumes-java.lang.String-) para hacer que únicamente se ejecute el handler si la petición a /user/profile contiene en su cabecera el tipo MIME *text/html*, de lo contrario no se hará matching con esa ruta y se seguirá en el proceso de búsqueda de rutas.

Cuando se indica el tipo MIME, se puede utilizar el carácter \* como comodín para omitir una de las dos partes del tipo

```java
router.route("/user/profile")
    .consumes("*/html")
    .handler( ... );

router.route("/user/me")
    .consumes("text/*")
    .handler( ... );
```

Otra característica que podemos aplicar a este tipo de ruta es que podemos combinar varios tipos para así poder responder a todos ellos desde un mismo handler.

```java
router.route("/user/profile")
    .consumes("text/plain")
    .consumes("text/html")
    .handler( ... );
```

Al igual que se puede definir el tipo MIME para la petición, también podemos hacer que nuestra ruta solo ejecute su handler si el cliente que ha enviado la petición acepta como respuesta el tipo MIME que indicamos.

```java
router.route("/user/profile")
    .produces("application/json")
    .handler(routingContex -> {
        HttpServerResponse response = routingContext.response();
        response.putHeader("content-type", "application/json");
        
        ...
    });
```

En este caso se usa el método [produces](http://vertx.io/docs/apidocs/io/vertx/ext/web/Route.html#produces-java.lang.String-) para indicar el tipo MIME de respuesta que el servicio va a retornar. También podemos combinar varios tipos y obtener el preferido del cliente con la function [getAcceptableContentType](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#getAcceptableContentType--).

```java
router.route("/user/profile")
    .produces("application/json")
    .produces("application/xml")
    .handler(routingContext -> {
        String contentType = routingContext.getAcceptableContentType();
        ...
    });
```

## Montar rutas encima de otras
 
Una opción muy interesante que nos permite realizar Vert.x, es montar un router encima de otro. Gracias a esto podemos repartir la funcionalidad entre distintos routers para más tarde poder reutilizarlos en aplicaciones diferentes o sobre distintos puntos de montaje:

```java
Router apiRouter = Router.router(vertx);
apiRouter.get("/user/profile")
    .handler( ... );

apiRouter.post("/user/profile")
    .handler( ... );


Router appRouter = Router.router(vertx);
appRouter.router("/static/*")
    .handler( ... );

appRouter.mountSubRouter("/api", apiRouter);
```

Como se puede ver tenemos dos objetos Router *apiRouter* y *appRouter*. El primero de ellos ha sido montado sobre el segundo con la función [mountSubRouter](http://vertx.io/docs/apidocs/io/vertx/ext/web/Router.html#mountSubRouter-java.lang.String-io.vertx.ext.web.Router-) usando el punto de montaje */api*, lo que quiere decir que ahora para llamar a las rutas del primer router tendremos que anteponer la cadena indicada.

```none
/api/user/profile
```

## Manejo de errores

Por defecto, Vert.x proporciona un manejador de errores cuando se pide una ruta que no se ha definido. Este manejador devuelve un código de estado 404 con el mensaje *Resource not found*. Para personalizarlo podemos hacer un manejado que se ejecute el último de todos y personalizar nosotros el error devuelto:

```java
router     
    .route()     
    .last()
     .handler(routingContext -> {         
        routingContext.response().setStatusCode(404);
         routingContext.response().end("Not Found");     
    });
```

Creamos un *route* sin ningún tipo de ruta asociada y le indicamos que queremos que se situe en la última posición de todas las rutas registradas con el método [last](http://vertx.io/docs/apidocs/io/vertx/ext/web/Route.html#last--). Finalmente en su manejador ponemos el código de estado 404 y contestamos la petición con el mensaje *Not Found*.

Además de esta forma de dar solución a los errores 404, también podemos manejar los errores que se producen dentro de cada handler indicando que la route definida tiene un [failureHandler](http://vertx.io/docs/apidocs/io/vertx/ext/web/Route.html#failureHandler-io.vertx.core.Handler-) 

```java
router 
    .get("/")
     .handler(routingContext -> {
        if (new Random().nextBoolean()) {
            throw new RuntimeException("Error");         
        } else {             
            routingContext.response().end("Hello World!");         
        }     
    })     
    .failureHandler(routingContext -> {
        routingContext.response().setStatusCode(500)         
        routingContext.response().end("Error in handler");     
    });
```

En el ejemplo anterior cada vez que se lance la excepción entrará por el *failureHandler* y devolverá al cliente un error 500 y el mensaje *Error in handler*.

## Peticiones con datos en el cuerpo

Cuando realizamos peticiones podemos enviar parámetros tanto en la url como en el cuerpo de la petición. Anteriormente vimos como poder recoger esos parámetros de la url con el método [getParam](http://vertx.io/docs/apidocs/index.html?io/vertx/ext/web/Route.html). En cambio para poder recoger los parámetros en el cuerpo de las peticiones tenemos que activar un handler. Esto lo podemos hacer añadiendo la siguiente linea antes de cualquier petición que vaya a necesitar obtener datos:

```java
router.route().handler(BodyHandler.create());
```
A partir de ese momento, podemos acceder a los parámetros que vienen en el cuerpo de la petición. Para acceder a ellos podemos utilizar el método [getBodyAsJson](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#getBodyAsJson--) si sabemos que los datos vienen en ese formato, [getBodyAsString](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#getBodyAsString--) si los queremos obtener como un String y [getBody](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#getBody--) para obtener un [Buffer](http://vertx.io/docs/apidocs/io/vertx/core/buffer/Buffer.html).

```java
router.route().handler(BodyHandler.create());

...

router     
    .post("/user")     
    .handler(routingContext -> {         
        System.out.println("Parameters are " + routingContext.getBodyAsString());     
    });
```

Si la información que se envía en la petición proviene de un formulario, podemos obtener todos los datos en un mapa con el método [formAttributes](http://vertx.io/docs/apidocs/io/vertx/core/http/HttpServerRequest.html#formAttributes--):

```java
router
    .post("/user")
    .handler(routingContext -> {
        MultiMap params = routingContext.request().formAttributes();
    });
```

En algunas ocasiones, en los formularios nos interesa que se envíen ficheros al servidor. Para poder acceder a estos ficheros lo hacemos mediante el método [fileUploads](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#fileUploads--) del RoutingContext, que nos devolverá un Set de [FileUpload](http://vertx.io/docs/apidocs/io/vertx/ext/web/FileUpload.html) con el que podremos acceder a varias propiedades del fichero y poder copiarlo al destino que queramos.

```java
router
    .post("/user/photo")
    .handler(routingContext -> {
        Set<FileUpload> uploads = routingContext.fileUploads();

        //Do something with the files
    });
```

## Resumiendo

Aquí finaliza esta primera entrada donde hemos visto como se gestionan las rutas en una aplicación desarrollada con Vert.x Web, como podemos obtener y trabajar con los parámetros que llegan tanto en la url de la petición como en el cuerpo de la misma y como gestionar los errores.

En la próxima entrada veremos algunos conceptos más avanzados como las cookies, el manejo de sesiones, uso de plantillas...