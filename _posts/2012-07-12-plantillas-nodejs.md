---
layout: post
comments: false
title: Plantillas en Node.js
---

Siguiendo con la serie de entradas que estoy haciendo sobre Node.js, ahora es el turno para trabajar con plantillas y poder crear nuestro contenido html de una forma más rápida y sencilla de lo que hemos visto hasta ahora. Existen varios motores de plantillas para Node como son: [Haml](https://github.com/visionmedia/haml.js), [CofeeKup](https://github.com/mauricemach/coffeekup), [Jade](http://jade-lang.com/), [EJS](https://github.com/visionmedia/ejs), [jQuery Templates](https://github.com/kof/node-jqtpl) y algunos otros. En esta entrada me voy a centrar en trabajar con Jade que es el motor de plantillas más popular para Node y muy fácil de usar.

Para comenzar tenemos que tener Node instalado en nuestro ordenador (si no lo tienes puedes darle un vistazo a la entrada de [Introducción a Node.js](/2012/05/27/introduccion-nodejs.html)), a continuación creamos una carpeta donde queramos almacenar el proyecto, abrimos un terminal y vamos hacia esa ruta. Una vez en ella vamos a instalar todas las librerías con las que vamos a trabajar, estás serán Express (que vimos en la entrada de [gestión de rutas con Node.js](/2012/06/16/gestion-de-rutas-nodejs.html)) y Jade. Para ello tecleamos en el terminal lo siguiente:

    > npm install express
    
Y cuando finalice la instalación de express:

    > npm install jade

Nuestro directorio de trabajo contendrá ahora una carpeta llamada *node_modules* donde estarán guardados esos módulos que acabamos de instalar. Continuaremos creando los diferentes directorios que tendrá nuestro proyecto para tenerlo todo organizado desde el principio. Así pues, vamos a crear un nuevo directorio que llamaremos **views** donde almacenaremos las plantillas creadas y otro directorio llamado **public** donde pondremos todo el contenido estático como son ficheros JavaScript para el cliente, ficheros CSS, imágenes...

Con nuestro directorio de trabajo completamente creado, ahora es el turno de comenzar a escribir código, en el directorio raíz vamos a crear un fichero al que llamaremos **server.js**. Lo primero que vamos a hacer en él es crear la configuración para que Node use correctamente tanto Express como Jade, para ello escribimos el siguiente contenido:

<!--more-->

{% highlight javascript linenos %}
var express = require('express');

var app = express.createServer();

app.configure(function() {
    app.set('views', __dirname + '/views');
    app.set('view options', { layout: false });
    app.use(express.bodyParser());
    app.use(express.static(__dirname + '/public'));
});
{% endhighlight %}

La primera linea, como ya sabemos, importa el modulo de Express para poder trabajar con él, a continuación se crea el servidor y a partir de la linea 5 es donde tenemos la configuración de nuestra aplicación. El método **configure** es proporcionado por Express y nos permite configurar los requerimientos de nuestra aplicación. Cada linea de la configuración indica lo siguiente:

* **app.set('views', __dirname + '/views'):** indicamos el directorio donde estarán las plantillas. __dirname es una variable global que indica el directorio del script que se está ejecutando actualmente.

* **app.set('view options', { layout: false }):** indicamos que vamos a utilizar una plantilla base como layout en nuestras vistas. Hay que tener cuidado con esta propiedad ya que para indicar que queremos usar un layout la tenemos que poner a false y si no queremos usarlo a true cosa que lleva a bastantes confusiones.

* **app.use(express.bodyParser()):** como vimos en la entrada sobre las [rutas](/2012/06/16/gestion-de-rutas-nodejs.html), el bodyParser es útil para poder recuperar el contenido de los formularios.

* **app.use(express.static(__dirname + '/public')):** indicamos la ruta donde se encuentra el contenido estático de nuestra aplicación, ficheros JavaScript, CSS, imágenes...

Finalizada la configuración, pasamos ahora a crear la primera ruta de la aplicación. Esta primera ruta simplemente se encarga de renderizar una plantilla y el código que tenemos que añadir al fichero **server.js** es este:

{% highlight javascript linenos %}
app.get('/', function(req, res) {
    res.render('index.jade');
});
{% endhighlight %}

Esta función simplemente llama al método **render** del parámetro **res** pasándolo el nombre de la plantilla que tiene que renderizar y este se encarga de todo el proceso. El siguiente paso es crear la plantilla, como hemos dicho antes que vamos a utilizar un layout la primera plantilla que crearemos será esa, para ello vamos a la carpeta views de nuestro directorio de trabajo y creamos un fichero al que llamaremos **layout.jade** y cuyo contenido será el siguiente:

{% highlight jade linenos %}
doctype html
html
  head
    link(rel='stylesheet', href='/css/style.css')
    title Ejemplo de plantillas con Jade
  body
    #wrap
      header
        h1 Ejemplo con Node.js y Jade

      content
        nav
          ul
            li
              a(href='/') Inicio
            li 
              a(href='/formulario') Formulario
            li
              a(href='/elementos') Elementos
        block text
{% endhighlight %}

Aquí tenemos nuestra primera plantilla realizada en jade, a primera vista puede parecer algo complicado pero si la vemos con detenimiento podremos ver que es bastante sencillo y simple crear plantillas. Comenzamos con el doctype e indicamos que es html, simplemente con esto al compilar la plantilla jade se encarga de escribir el doctype de HTML5 en la plantilla, a continuación en la siguiente linea escribimos html que jade traducirá en la etiqueta de apertura de un documento html. La linea 3 se encarga de poner la etiqueta de apertura de la cabecera del documento. Como podemos advertir esta linea está identada, la identación es muy importante en jade ya que gracias a ella se indica que elementos están contenidos dentro de otros. De esta forma la etiqueta head está contenida dentro de la etiqueta html. Dentro de la etiqueta de head (de nuevo identadas), en las lineas 4 y 5 se a declarado una etiqueta link y otra title. Como nos imaginaremos la etiqueta link se encargará de enlazar algún tipo de documento. Para indicar los atributos que le queremos poner a una etiqueta los tenemos que poner entre paréntesis y separarlos por una , al igual que aparece en el ejemplo donde se enlaza una hoja de estilo e indicamos su atributo rel y su atributo href. Por su parte para la etiqueta title queremos indicar un texto y tenemos varias formas de hacerlo. La más sencilla es poner el texto al lado de la etiqueta como se muestra en el código anterior. De esta forma todo el texto que pongamos al lado de la etiqueta se interpretará como el texto que se va a poner entre las etiquetas <title> y </title>. Otra forma de indicar que queremos introducir texto es poniendo un . al lado de la etiqueta de la siguiente forma:

{% highlight jade linenos %}
title.
  Esto tambien es un texto valido
{% endhighlight %}

La tercera forma de poner texto es mediante el signo **\|**

{% highlight jade linenos %}
title
  | Esto también es un texto valido
{% endhighlight %}

Una vez que tenemos claro como introducir texto pasamos a la siguiente linea la cual es el body y está a la misma altura de la etiqueta head. De esta forma indicamos que la etiqueta head termina en ese punto y comienza la etiqueta body. Dentro del body vamos a crear un div cuyo id va a ser wrap para que contenga todo el contenido de nuestra página, como vemos en la linea 7 crear un div con un id es muy sencillo y solo tenemos que poner el valor de la propiedad id que va a tener el div, precedido por el símbolo #. Otra forma para crear este div podría haber sido la siguiente div(id="wrap"). Dentro del div crearemos una etiqueta header y  dentro de esa un h1 que contendrá el texto de la cabecera. A continuación y a la altura de la etiqueta header ponemos la etiqueta content que es donde pondremos todo el contenido de las páginas. En la linea 12 creamos la etiqueta nav, identada dentro de content, para poner nuestro menú de navegación. Dentro de la etiqueta nav crearemos una lista y cada uno de sus elementos contendrán une enlace con el atributo href que indiquemos dentro de los paréntesis y el texto que mostramos después de los paréntesis. Finalmente tenemos la etiqueta block a la que le hemos dado como nombre text. Esta etiqueta se encargará de que todas las plantillas que hereden de este layout puedan poner el contenido que quieran donde aparece este bloque. La etiqueta block la podemos poner en cualquier sitio de nuestra estructura, tanto en el head para poder modificar el titulo en cada plantilla, como entre medias del código o al final, como es el caso.

Como vemos con este ejemplo crear la estructura de una página con jade es muy sencillo. Para el resto de etiquetas html que no se han visto la idea es la misma. Pero continuemos un poco, ya tenemos el layout base, ahora vamos a crear la plantilla para la pagina principal, creamos un fichero nuevo dentro de la carpeta view al que llamaremos **index.jade** y le pondremos el siguiente contenido:

{% highlight jade linenos %}
extends layout

block text
  #content.
    Bienvenido a la página de ejemplo para mostrar como funcionan las 
        plantillas de jade. 
    Accede a los diferentes apartados desde el menú de la izquierda para 
        que puedas ver algunas de las características con las que podemos 
        trabajar con ayuda de Jade
{% endhighlight %}

La primera linea indica que esta vista va a extender de la plantilla layout, en este caso no es necesario indicarle la extensión simplemente con el nombre de la plantilla es suficiente. En la linea 3 de nuevo ponemos la etiqueta block pero en esta ocasión indica que hay que sustituir el contenido de la etiqueta block llamada text en el layout por todo lo que venga a continuación. Lo que viene a continuación es un simple texto de información.

Ya tenemos un layout y una primera plantilla de nuestra aplicación, vamos a trabajar un poco más con las plantillas y vamos a ver ahora como crear un formulario para enviar datos. Volvemos al fichero **server.js** y le añadimos el siguiente código para que pueda controlar una nueva ruta de nuestra aplicación:


{% highlight javascript linenos %}
app.get('/formulario', function(req, res) {
    res.render('form.jade');
});
{% endhighlight %}

De nuevo simplemente hacemos que se renderice una plantilla. Esta plantilla se llamara **form.jade** y la crearemos en la carpeta views con el siguiente contenido.

{% highlight jade linenos %}
extends layout

block text
  #content
    if typeof(mensajeError) != 'undefined'
      p.error= mensajeError

    form(action='/enviar', method='post')
      div Escribe un mensaje
      br
      div
        label Nombre:
        br
        input(name='nombre')

      div
        label Texto:
        br
        textarea(name='texto', rows='5', cols='30')
  
      div
        button Enviar
{% endhighlight %}

De nuevo la primera linea indica que esta plantilla extiende de layout y la linea 3 de nuevo indica que el contenido que aparece a continuación se insertará en la etiqueta block text del layout. Este contenido tendrá un div con el id content. La linea 5 tiene una estructura de control la cual comprueba si la variable mensajeError existe, en caso afirmativo se crea una etiqueta p con la clase error y el contenido de la variable mensajeError. Como vemos aplicarle una clase a un elemento es tan sencillo como poner el nombre de la clase precedido de un . a continuación de la etiqueta, otra forma de indicar una clase es mediante los atributos p(class="error"). La forma de asignar el contenido de una variable como un texto es poniendo el signo = pegado a la etiqueta y a continuación la variable.

Después de esta etiqueta de control vemos que se crea el form con dos atributos, el action y el method. El siguiente contenido es fácilmente identificable, se crea un input para introducir el texto y un textarea, ambas se configuran con los atributos que queramos y finalmente se crea un botón para enviar el formulario.

Como hemos indicado en el formulario el action apunta a la ruta /enviar, así que es hora de crear esa ruta. Volvemos al fichero **server.js**.

{% highlight javascript linenos %}
app.post('/enviar', function(req, res) {
    if( req.body.nombre == '' )
        res.render('form.jade', { 
            mensajeError: 'El nombre es un campo requerido'
        });
    else
        res.render('formContent.jade', {
            nombre: req.body.nombre,
            texto: req.body.texto
        });
});
{% endhighlight %}

Aquí tenemos algo más de código. Lo primero que hacemos es comprobar si el campo nombre ha sido rellenado, en caso de que esté en blanco volvemos a renderizar la plantilla del formulario pero en esta ocasión le pasamos un mensaje de error en la variable **mensajeError**. Ahora podemos ver que funcionalidad tendrá el if que pusimos en la plantilla y como se rellenara esa variable. Si por el contrario el valor del nombre si que esta rellenado, renderizamos otra plantilla llamada **formContent** a la cual le pasamos dos variables con el nombre que ha indicado el usuario en el campo nombre y el texto.

A continuación creamos el fichero **formContent.jade** dentro de la carpeta **views** y escribimos lo siguiente:

{% highlight jade linenos %}
extends layout

block text
  #content
    p Hola #{nombre}

    p Tu mensaje ha sido: #{texto}
{% endhighlight %}

Seguimos extendiendo del layout y el contenido de esta pagina es muy sencillo, simplemente tiene dos elementos p, el primero para mostrar el nombre y el segundo para el texto. Como vemos, para escribir el valor de una variable en mitad del texto simplemente tenemos que poner el nombre entre los carácteres *#{* y *}*.

Veamos ahora una última característica de las plantillas Jade. Supongamos que tenemos una lista de elementos que hemos obtenido bien leyendo de un fichero, de una base de datos o como queramos y queremos mostrarlos todos por pantalla. Para eso necesitaremos una opción para poder iterar por los elementos y Jade también nos proporciona un mecanismo para realizar esta operación. Vamos al fichero **server.js** y ponemos el siguiente método:

{% highlight javascript linenos %}
app.get('/elementos', function(req, res) {
    var colors = new Array('Rojo', 'Blanco', 'Azul', 'Amarillo', 'Negro');

    res.render('elementos.jade', {
        elementos: colors
    });
});
{% endhighlight %}

En este ejemplo, he optado por tener un array con varios elementos y lo que vamos a hacer es enviarlos a la plantilla **elementos.jade** en una variable como hemos hecho anteriormente. A continuación vamos a la carpeta **views** creamos el fichero **elementos.jade** y ponemos el siguiente contenido:

{% highlight jade linenos %}
extends layout

block text
  #content
    ul
      for color in elementos
        li=color
{% endhighlight %}

Con estas pocas lineas de código hemos conseguido iterar por todos los elementos y mostrarlos en una lista. Antes de finalizar quería aclarar un cosa, tanto las sentencia *if* como la sentencia *for* que se se escriben en el código tiene una sintaxis diferente a lo que es habitual en JavaScript, esto se debe a que Jade proporciona esta otra sintaxis para que sea algo más amigable, pero también se puede usar las sentencias en JavaScript normal como se puede ver en este ejemplo:

{% highlight jade linenos %}
-if( typeof(mensajeError) != 'undefined' )
   p.error= mensajeError


-for (i = 0; i < elementos.length; i++)
  li=elementos[i]
{% endhighlight %}

Simplemente hay que tener en cuenta que si queremos utilizar sentencias en JavaScript tendremos que perecederas del símbolo *-* para que funcione correctamente.

Hasta aquí esta pequeña introducción a Jade, si queréis ver más características de este motor de plantillas o como usar alguna otra característica podéis visitar este [manual](https://github.com/visionmedia/jade/blob/master/Readme.md) creado por los autores de Jade.

Entradas relacionadas:

* [Introducción a Node.js](/2012/05/27/introduccion-nodejs.html)
* [Gestión de rutas en Node.js](/2012/06/16/gestion-de-rutas-nodejs.html)
* [Conexión a base de datos con Node.js](/2012/08/28/conexion-base-datos-nodejs.html)