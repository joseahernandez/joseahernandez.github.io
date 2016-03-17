---
layout: post
comments: false
title: Gestión de rutas en Node.js
---

Como vimos en la [introducción a Node.js](/2012/05/27/introduccion-nodejs.html) de una forma muy sencilla podemos construir un servidor web y proporcionar una respuesta con este framework. A continuación vamos a mejorarlo permitiendo utilizar rutas amigables. Para ello lo primero que vamos a necesitar es instalarnos el paquete [express](http://expressjs.com) que nos proporcionará herramientas para poder realizar esta tarea fácilmente. Gracias al gestor de paquetes que incorpora Node,  podemos instalar express de una manera muy sencilla. Accedemos a un terminal y navegamos hasta el directorio en el que estemos trabajando, una vez en él tecleamos lo siguiente:

    >npm install express

Cuando finalice la descarga se instalará automáticamente y ya podemos comenzar a trabajar con él. Si nos fijamos atentamente, se nos habrá creado una carpeta llamada node_module y dentro de ella tendremos instalado express.

El primer paso que vamos a hacer es crear un servidor web, para ello creamos un fichero al que llamaremos **server.js** y su contenido será el siguiente:

<!--more-->

{% highlight javascript linenos %}
var express = require('express');

var app = express.createServer();

app.get('/', function(req, res){
    res.send('Hola mundo');
});

app.listen(1333);
{% endhighlight %}

En la primera linea del fichero importamos el modulo de express y seguidamente creamos un servidor con la llamada a **createServer**. Después de crear el servidor es cuando se crean las rutas, en este ejemplo se ha creado una ruta para la pagina raíz. Para ello utilizamos el objeto del servidor web y decimos que escuche una petición de tipo **get** a la raíz de nuestro sitio */*. Esto lo realizamos con la función **app.get('/')**. Además indicamos que cuando se realice esta petición se ejecute el callback asociado que hemos pasado como segundo parámetro a la función. El callback que hemos definido simplemente envía un mensaje de *Hola mundo* al cliente.

Para enviar el mensaje al cliente hemos utilizado el método **send**. Este método acepta cualquier tipo de elemento que le pasemos, una cadena de texto, un objeto json, etiquetas html e incluso códigos de estado. Este método también se encarga de indicar automáticamente el content-type correcto, aunque si queremos indicarlo nosotros mismos lo podemos hacer utilizando el método del request **contentType**. Una cosa que tenemos que tener en cuenta cuando usamos el método **send**, es que ocurre lo mismo que cuando usamos el método **end**, que finaliza la conexión y lo prepara todo para enviarlo al cliente. Por ello si queremos poder enviar más datos es recomendable utilizar el método **write**.

Finalmente para que arranque la aplicación indicamos mediante el método **listen** el puerto donde queremos que escuche. Ahora es el momento de probar nuestro ejemplo, accedemos de nuevo al terminal y tecleamos:

    >node server.js

Si accedemos con un navegador a la url **http://localhot:1333** obtendremos el mensaje *Hola mundo*.

Vamos a añadir algunas rutas más a nuestro ejemplo para ver algunas muestras de cosas que podemos hacer con la ayuda de express.

{% highlight javascript linenos %}
app.get('/saluda/:nombre', function(req, res) {
    res.send('Hola ' + req.params.nombre);
});
{% endhighlight %}

En esta ocasión le hemos indicado que la ruta recibirá un parámetro, esto lo hacemos poniendo el simbolo **:** delante del nombre de la variable que vamos a pasar. Para acceder a esta variable lo hacemos mediante el método **req.params.nombre** donde *nombre* es como hemos llamado a la variable en la ruta sin el símbolo de los dos puntos. Si accedemos a la url **http://localhost:1333/saluda/Jose** obtendremos como respuesta el mensaje *Hola Jose*.

Veamos otro ejemplo enviando esta vez código html al cliente.

{% highlight javascript linenos %}
app.get('/formulario', function(req, res) {

    res.charset = 'utf8';
    res.header('Content-Type', 'text/html');
    
    res.write('<!DOCTYPE html><html><head><title>Ejemplo Node.js</title></head><body>');
    res.write('<form action="/envio" method="post">');
    res.write('<label>Ciudad: </label>');
    res.write('<input type="text" name="ciudad" />');
    res.write('<input type="submit" value="Enviar" />');
    res.write('</form>');
    res.end('</body></html>');
});
{% endhighlight %}

En esta ocasión con ayuda de los métodos **write** y **end** hemos creado un pequeño formulario html y lo enviamos al cliente cada vez que se solicite la url **http://localhost:1333/formulario**. Aunque esta es una forma válida de enviar contenido html al cliente, no es ni la más manera más elegante ni la más fácil de hacer. Por ello, en la próxima entrada hablaré de como utilizar plantillas html para Node.js que es la mejor forma para crear el contenido html.


Hay que tener en cuenta que en las dos primeras lineas de la función hemos indicado el juego de caracteres que se va a utilizar *utf8* y que el tipo de contenido sera *text/html*. Esto lo hacemos porque en esta ocasión vamos a devolver código html y no simplemente texto como en las ocasiones anteriores.


Como hemos creado un formulario veamos ahora como recuperar los datos que se introducen en él. Para que express pueda recuperar el contenido de un formulario tenemos que usar un middleware para que se encargue de parsear los datos del formulario. Para ello utilizaremos el middleware **bodyParse** que proporciona express. Para hacer uso de él tendremos que añadir la siguiente linea a nuestro fichero de código:

{% highlight javascript linenos %}
app.use(express.bodyParser());
{% endhighlight %}

Es importante que esta linea la añadamos antes de comenzar a declarar las rutas, por ejemplo justo después de la llamada a la función **createServer**. A continuación veamos como recuperamos la información del formulario:


{% highlight javascript linenos %}
app.post('/envio', function(req, res) {
    res.send('Has indicado que eres de ' + req.body.ciudad);
});
{% endhighlight %}

Al formulario le indicamos como atributo action la ruta a **/envio** y como method **POST**, por ello en esta ocasión utilizamos el método **post** indicando que la llamada se realizará mediante post. Como podemos ver, para acceder a los datos del formulario simplemente tenemos que utilizar la instrucción **req.body** y a continuación indicar el nombre que le hemos dado al campo en el formulario.

De nuevo con muy poco código hemos creado bastante funcionalidad, a continuación dejo el fichero completo para que veáis como queda:

{% highlight javascript linenos %}
var express = require('express');
var app = express.createServer();
app.use(express.bodyParser());

app.get('/', function(req, res) {
    res.send('Hola mundo');
});

app.get('/saluda/:nombre', function(req, res) {
    res.send('Hola ' + req.params.nombre);
});


app.get('/formulario', function(req, res) {
    res.charset = 'utf8';
    res.header('Content-Type', 'text/html');
    
    res.write('<!DOCTYPE html><html><head><title>Ejemplo Node.js</title>' +
        '</head><body>');
    res.write('<form action="/envio" method="post" 
                       enctype="application/x-www-form-urlencoded">');
    res.write('<label>Ciudad: </label>');
    res.write('<input type="text" name="ciudad" />');
    res.write('<input type="submit" value="Enviar" />');
    res.write('</form>'); 
    res.end('</body></html>');
});

app.post('/envio', function(req, res) { 
    res.send('Has indicado que eres de ' + req.body.ciudad);
});

app.listen(1333);
{% endhighlight %}

En la próxima entrada, como ya he mencionado antes, veremos el uso de plantillas para facilitar la creación de código html.

Entradas relacionadas:

* [Introducción a Node.js](/2012/05/27/introduccion-nodejs.html)
* [Plantillas en Node.js](/2012/07/12/plantillas-nodejs.html)
* [Conexión a base de datos con Node.js](/2012/08/28/conexion-base-datos-nodejs.html)