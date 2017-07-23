---
layout: post
comments: true
title: Vert.x Web II
---

Anteriormente, en la entrada [Vert.x Web I](http://josehernandez.xyz/2017/04/13/vertx-web-i.html) vimos como podemos comenzar a desarrollar una aplicación web con Vert.x y las facilidades que nos da para ello. En esta entrada completaremos algunas de las características que vimos en la primera para ver todas las caracteristicas básicas con las que poder desarrollar una aplicación completa. 

## Manejo de cookies

Vert.x proporciona una forma sencilla para manejar las cookies. Al igual que se hace para para los datos en el cuerpo de la petición, para poder acceder a las cookies tenemos que activar un handler. Este handler se llama [CookieHandler](http://vertx.io/docs/apidocs/index.html?io/vertx/ext/web/handler/CookieHandler.html) y lo activaremos de la siguiente forma:

```java
router.route().handler(CookieHandler.create());
```

Una vez activado, podemos obtener una [cookie](http://vertx.io/docs/apidocs/io/vertx/ext/web/Cookie.html) por su nombre con [getCookie](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#getCookie-java.lang.String-) u obtener todas ellas con [cookies](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#cookies--). El RoutingContext nos proporciona dos métodos, uno para añadir una cookie nueva [addCookie](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#addCookie-io.vertx.ext.web.Cookie-) y otro para eliminarlas [removeCookie](http://vertx.io/docs/apidocs/io/vertx/ext/web/RoutingContext.html#removeCookie-java.lang.String-)

```java
router.route().handler(CookieHandler.create());

router
    .post("/comment")
    .handler(routingContext -> {
        Cookie cookie = routingContext.getCookie("userInfo");
        String name = cookie.getValue();

        ...

        routingContext.addCookie(Cookie.cookie("userInfo", name));
    });
```

<!--more-->

## Manejo de sesiones

Las sesiones sirven para mantener información entre distintas peticiones http. En Vert.x las sesiones usan cookies para poder identificarlas, de forma que cuando llega al servidor una petición, a partir de la cookie se recuperar la información anteriormente guarda bajo este identificador.

Como las cookies son enviadas entre las peticiones y respuestas, a la hora de usar sesiones es recomendable utilizarlas bajo el protocolo HTTPS. De echo, en caso de no hacerlo Vert.x nos avisará con un warning.

De nuevo como viene siendo habitual, para utilizar las sesiones tendremos que activar un handler. En este caso el [SessionHandler](http://vertx.io/docs/apidocs/io/vertx/ext/web/handler/SessionHandler.html).

Para crear el SessionHandler antes tendremos que tener una instancia de una [SessionStore](http://vertx.io/docs/apidocs/io/vertx/ext/web/sstore/SessionStore.html). La SessionStore es el objeto encargado de almacenar los datos de la sesión para nuestra aplicación. Vert.x nos proporciona dos tipos de SessionStore [LocalSessionStore](http://vertx.io/docs/apidocs/io/vertx/ext/web/sstore/LocalSessionStore.html) y [ClusteredSessionStore](http://vertx.io/docs/apidocs/io/vertx/ext/web/sstore/ClusteredSessionStore.html).

Si usamos el tipo LocalSessionStore la sesión se guardará en la memoria de la instancia de Vert.x en la que se esté ejecutando, por lo tanto no será accesible desde otra instancia. Esta será la opción que seleccionaremos si únicamente vamos a utilizar una instancia o si usaremos sticky sessions:

```java
SessionStore store = LocalSessionStore.create(vertx, "myapp", 60000)
```

Con el método [create](http://vertx.io/docs/apidocs/io/vertx/ext/web/sstore/LocalSessionStore.html#create-io.vertx.core.Vertx-java.lang.String) indicaremos la instancia de vert.x, el nombre de la app, ya que nos permite tener varias apps distintas gestionadas por el mismo session store y si nos interesa el tiempo para que expire la sesión.

Por su parte el ClusteredSessionStore está indicada para almacenar las sesiones dentro de un cluster y poder acceder a ellas desde cualquier nodo.

```java
SessionStore store = ClusteredSessionStore.create(vertx, "myapp")
```

De nuevo con el método [create](http://vertx.io/docs/apidocs/io/vertx/ext/web/sstore/ClusteredSessionStore.html#create-io.vertx.core.Vertx-java.lang.String) indicando la instancia de vertx y el nombre de la app tendremos creada nuestra session store.

Una vez tenemos claro que tipo de SessionStore vamos a utilizar tenemos que crear un handler para las sesiones y añadirlo al route. Además, también tenemos que asegurarnos que tenemos un CookieHandler creado, ya que las sesiones utilizan cookies como hemos comentado antes.

```java
Router router = Router.router(vertx);

rotuer.route().handler(CookieHandler.create());
SessionStore store = ClusteredSessionStore.create(vertx);
SessionHandler sessionHandler = SessionHandler.create(store);

rotuer.route().handler(sessionHandler);
```

Una vez que tenemos la configuración finalizada, podemos acceder a la sesión desde los handlers para responder las peticiones a través del routingContext:

```java
router
    .post("/comment")
    .handler(routingContext -> {
        Session session = routingContext.session();
        String user = session.get("user");
    });
```
El objeto [Session](http://vertx.io/docs/apidocs/io/vertx/ext/web/Session.html) proporciona métodos básicos para obtener datos [get](http://vertx.io/docs/apidocs/io/vertx/ext/web/Session.html#get-java.lang.String-), guardar datos en la sesión [put](http://vertx.io/docs/apidocs/io/vertx/ext/web/Session.html#put-java.lang.String-java.lang.Object-) y eliminarlos de ella [remove](http://vertx.io/docs/apidocs/io/vertx/ext/web/Session.html#remove-java.lang.String-).

Una cosa a tener en cuenta con las sesiones es que las claves de los valores siempre tienen que ser cadenas, además si estamos usando un LocalSessionStore podemos guardar cualquier tipo de objeto, pero si usamos un ClusteredSessionStore estamos restringidos a tipos básicos, [Buffer](http://vertx.io/docs/apidocs/io/vertx/core/buffer/Buffer.html), [JsonObject](http://vertx.io/docs/apidocs/io/vertx/core/json/JsonObject.html), [JsonArray](http://vertx.io/docs/apidocs/io/vertx/core/json/JsonArray.html) o un objeto serializable.

## Recursos estáticos

En la entrada anterior vimos como se creaban rutas y se asociaban manejadores para darles respuesta a las peticiones de las mismas. Pero una aplicación web también contiene ficheros estáticos que hay que servirle al cliente como son los .css, .js. html… Para ello, Vert.x pone a nuestra disposición un [StaticHandler](http://vertx.io/docs/apidocs/io/vertx/ext/web/handler/StaticHandler.html) que se encarga de manejar estos recursos. Para activarlo lo haremos de la siguiente forma:

```java
router.route("/static/*").handler(StaticHandler.create());
```

Por defecto, el StaticHandler va a buscar todos los recursos a la carpeta webroot que esté en el mismo directorio que nuestro fichero .jar. Si no encuentra nada en ese directorio también buscará dentro del classpath de la aplicación. Lo que nos permite empaquetar todos los recursos de la aplicación en un jar y desplegar un único fichero con toda la aplicación. En caso de querer cambiar la carpeta webroot por otra, podemos usar el método [setWebRoot](http://vertx.io/docs/apidocs/io/vertx/ext/web/handler/StaticHandler.html#setWebRoot-java.lang.String-).


Vert.x cachea todos los recursos estáticos que se sirven desde el classpath en una carpeta llamada *.vertx* y que se encuentra en la misma ubicación desde la que se ejecuta la aplicación. De esta forma responde las peticiones de estos recursos de forma más rápida. En caso de querer desactivar esta característica (recomendable cuando se está desarrollando una aplicación) se debe añadir la propiedad **vertx.disableFileCaching** a true al sistema.

Además, al responder la petición de un recurso estático, Vert.x le añade las cabeceras *last-modified*, *date* y un *max-age* de un día para que los navegadores usen el recurso cacheado en vez de volver a hacer la petición.


## Plantillas

Cuando construimos una web con Vert.x, utilizar los métodos [write](http://vertx.io/docs/apidocs/io/vertx/core/http/HttpServerResponse.html#write-io.vertx.core.buffer.Buffer-) y [end](http://vertx.io/docs/apidocs/io/vertx/core/http/HttpServerResponse.html#end--) sirve para enviar la respuesta de las peticiones al cliente. Pero además de ser muy engorroso dificulta mucho el mantenimiento del contenido, sobretodo si son cadenas que contienen todo el código html de una página. Por ello, lo normal es usar plantillas que nos facilitan ese mantenimiento, además de hacer que tengamos todas las vistas separadas de la lógica de nuestra aplicación.

Vert.x soporta varios de los motores de plantillas más populares y para usarlos simplemente tenemos que importar la dependencia correspondiente a cada uno. Los motores que soporta Vert.x y las dependencias necesarias para usarlos son los siguientes:

* [MVEL](http://mvel.codehaus.org/MVEL+2.0+Templating+Guide):  io.vertx:vertx-web-templ-mvel:3.4.1
* [Jade](https://github.com/neuland/jade4j): io.vertx:vertx-web-templ-jade:3.4.1
* [Handlebars](https://github.com/jknack/handlebars.java): io.vertx:vertx-web-templ-handlebars:3.4.1
* [Thymeleaf](http://www.thymeleaf.org): io.vertx:vertx-web-templ-thymeleaf:3.4.1
* [Apache FreeMarker](http://freemarker.org): io.vertx:vertx-web-templ-freemarker:3.4.1
* [Pebble](http://www.mitchellbosecke.com/pebble/home/): io.vertx:vertx-web-templ-pebble:3.4.0-SNAPSHOT

Para usar cualquiera de los template engines mencionados anteriormente,  simplemente tenemos que crear una instancia de [TemplateEngine](http://vertx.io/docs/apidocs/io/vertx/ext/web/templ/TemplateEngine.html) y llamar a su método [render](http://vertx.io/docs/apidocs/io/vertx/ext/web/templ/TemplateEngine.html#render-io.vertx.ext.web.RoutingContext-java.lang.String-io.vertx.core.Handler-).

Si creamos un template de Jade dentro de *resources/templates/index.jade* con la siguiente plantilla:

```html
doctype html
html
    head
        title="Hello World"
    body
        p="Hello World,  " + context.get('name')
```

Y en nuestra verticle creamos el template engine y lo llamamos dentro del handler de la ruta que nos interese:

```java
TemplateEngine templateEngine = JadeTemplateEngine.create();

. . .

router
  .get("/")
  .handler(routingContext -> {
    routingContext.put("name", "Jose");
    templateEngine.render(routingContext, "templates/index", result -> {
      if (result.success()) {
        context.response().end(result.result());
      } else {
        context.response().setStatusCode(500).end("Internal error");
      }
    });
  });
```

El motor se encargará de transformar esa plantilla con los datos de contexto introducidos en código html similar al siguiente:

```html
<!DOCTYPE html>
<html>
    <head>
        <title>Hello World</title>
    </head>
    <body>
        <p>Hello World, Jose</p>
    </body>
</html>
```

## Seguridad contra ataques CSRF

Los exploits [CSRF](https://es.wikipedia.org/wiki/Cross-site_request_forgery) son uno de los ataques más comunes a los sitios web. Para protegernos contra estos ataques Vert.x proporciona un handler que genera un token aleatorio y espera que en la siguiente petición sea enviado como una cabecera de la misma. La clave con la que se espera encontrar el token en la cabecera es *X-XSRF-TOKEN*. 

En el caso de que estemos desarrollando una aplicación web que no es una [SPA](https://es.wikipedia.org/wiki/Single-page_application) y no podamos añadir cabeceras a las peticiones, podemos incluir en un campo del formulario (normalmente de tipo hidden) el token para que se envie al servidor con el cuerpo del formulario:


```html
doctype html
html
    head
        title="Register user"
    body
        form(method='POST' action='/register')
            div
                label(for='username') Name:
                input#name(type='text' name='username')

            div
                label(for='password') Password:
                input#password(type='password' name='password')

            div
                label(for=‘retypePassword’) Retype Password:
                input#retypePassword(type=‘password’, name=‘retypePassword’)
            div
                input(type='hidden' name='X-XSRF-TOKEN' value=context.get("csrf"))
                button(type='submit') Sign up

```

En el formulario anterior se ha añadido un campo *hidden* con nombre *X-XSRF-TOKEN* al que se le a asignado el valor del campo *csrf* del context. El manejador que se encarga de renderizar este formulario será el siguiente:

```java
. . .

router.route().handler(BodyHandler.create());
router.route().handler(CookieHandler.create());
router.route().handler(CSRFHandler.create("secret-key"));

router.get("/").handler(context -> {
  context.put("csrf", context.get("X-XSRF-TOKEN"));
  templateEngine.render(context, "templates/index", result -> {
    if (result.succeeded()) {
      context.response().end(result.result());
    } else {
      context.response().setStatusCode(500).end("Internal error");
    }
});

router.post("/register").handler(context -> {
  . . .
  context.response().end("User register successful");
});
```

Se ha habilitado el *BodyHandler*, el *CookieHandler* y el [CSRFHandler](http://vertx.io/docs/apidocs/io/vertx/ext/web/handler/CSRFHandler.html) que es el que nos activa la seguridad contra ataques CSRF. A continuación, en el handler que va a invocar la plantilla añadimos en el context el token que se ha generado llamando a *context.get("X-XSRF-TOKEN")* y este token será el que se renderizará en el campo hidden del formulario. Una vez que se envíe el formulario, el propio Vert.x se encargará de comprobar que el token es el que corresponde para permitir la operación o generar un error.


## Favicon

Al igual que para los recursos estáticos, Vert.x tiene un handler para el favicon del sitio web que estamos creando, este handler es el [FaviconHandler](http://vertx.io/docs/apidocs/io/vertx/ext/web/handler/FaviconHandler.html) que por defecto buscará el fichero *favicon.ico* en el classpath, aunque podemos indicarle el path donde buscarlo a la hora de crearlo, así como el tiempo que se puede cachear.

```java
router.route().handler(FaviconHandler.create());
```

## Loguear peticiones HTTP

Otro de los handlers interesantes que incluye Vert.x es el [LoggerHandler](http://vertx.io/docs/apidocs/io/vertx/ext/web/handler/LoggerHandler.html). Con él podemos loggear todas las peticiones HTTP que recibamos en nuestro servidor.

```java
router.route().handler(LoggerHandler.create());
```

## Conclusión

Con esta entrada y la anterior, hemos podido ver algunos de los componentes que pone a nuestra disposición Vert.x para crear una aplicación web. Gracias a ellos y a algunos otros que no hemos comentado podemos crear desde pequeñas aplicaciones hasta las más complicadas que necesitemos. 

Si estais interesados en conocer más cosas sobre Vert.x os recomiendo que visites su [sitio web](http://vertx.io) así como su [blog](http://vertx.io/blog/) donde podeis encontrar entradas muy interesantes.
