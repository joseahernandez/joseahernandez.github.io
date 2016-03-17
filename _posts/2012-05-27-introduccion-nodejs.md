---
layout: post
comments: false
title: Introducción a Node.js
---

[Node.js](http://nodejs.org) es una plataforma de desarrollo construida en base al motor JavaScript de Chrome. Node nace con el objetivo de facilitar la creación de aplicaciones que sean fácilmente escalables en la red. Utiliza un modelo orientado a eventos no bloqueante, lo que quiere decir, que atiende paralelamente a todas las peticiones que recibe. Gracias a esto, node es ideal para utilizarse en aplicaciones que tienen un uso intensivo de datos en tiempo real.

Para trabajar con Node.js necesitamos saber JavaScript, ya que toda la programación se realizará con este lenguaje. Para comenzar a desarrollar, lo primero que necesitamos es [descargarnos Node](http://nodejs.org/#download). Existen versiones para Windows y Mac, así como la posibilidad de descargar los fuentes para compilarlo. Los usuarios de Linux tendrán que comprobar si existe el paquete en los repositorios de su distribución o en caso contrario descargar los fuentes.

Una vez descargado e instalado crearemos nuestro primer servidor web. Para ello vamos a crear un fichero llamado *servidor.js*. En este fichero pondremos el siguiente código:

<!--more-->

{% highlight javascript linenos %}
var http = require('http');

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hola mundo');
}).listen(1333, '127.0.0.1');

console.log('Servidor en marcha');
{% endhighlight %}

Simplemente con estas 6 líneas ya tenemos un servidor web montado. Expliquemos a continuación cada una de las líneas del programa. Para comenzar la primera línea hace uso de la función **require** que se encarga de importar el modulo http. Este modulo es el encargado de realizar las tareas que están relacionadas con este protocolo, para más información se puede ver la [documentación del modulo http](http://nodejs.org/api/http.html).

Una vez importado el modulo y almacenado en la variable **http** nos ponemos a trabajar con él. Lo primero que hacemos es llamar a la función **createServer** que se encarga de crear un nuevo objeto de tipo servidor web. Esta función, opcionalmente, puede recibir un callback que se ejecutará cada vez que se reciba una petición. En nuestro caso, como nos interesa poder responder a las peticiones la implementaremos. Este callback recibe dos parámetros **req** (request o petición) y **res** (response o respuesta). Con el request podemos acceder a los datos que recibimos por parte del cliente, mientras que con el response podemos definir que le enviamos de nuevo al cliente.

Dentro del callback y haciendo uso de la variable para la respuesta, **res**, utilizamos el método **writeHead** para definir una cabecera para nuestra respuesta. El único parámetro obligatorio de esta función es el primero que es el código de respuesta HTML, en nuestro caso 200 porque la petición es correcta. En el segundo parámetro, opcionalmente, podemos indicarle las cabeceras. En el ejemplo se le indica el content-type y decimos que es texto plano.

A continuación vamos a contestar al cliente con un mensaje, en el ejemplo se ha utilizado la función **end**. Esta función se encarga de indicarle al servidor que tanto la cabecera como el contenido están listos para ser enviados. Opcionalmente se le pude pasar dos parámetros, el primero de ellos son los datos que queremos insertar en el cuerpo de la respuesta, en este caso el mensaje y el segundo parámetro es la codificación de los datos. Por defecto la codificación siempre es utf8. Si quisiéramos enviar más datos podríamos haber utilizado la función **write** cuyo primer parámetros son los datos a enviar en el cuerpo del mensaje y su segundo parámetro, opcional, es también la codificación. Pero siempre recordando que la última llamada tiene que ser a **end** para indicar que todo esta listo.

Finalmente terminamos el callback y con el objeto de tipo servidor web devuelto por la función **createServer**, llamamos al método **listen** para que comience a aceptar peticiones. Esta función tiene como parámetros el puerto donde escuchará las peticiones, el 1333 en el ejemplo y opcionalmente la ip desde la que se aceptarán conexiones, en el ejemplo localhost (127.0.0.1).

Para acabar con el ejemplo tenemos la llamada a **console.log** que se encargará de mostrar por la pantalla donde se ejecuta el servidor el log de los mensajes que le indiquemos.

Para probar que todo funciona correctamente abrimos un terminal y vamos al directorio donde tengamos guardado el archivo que acabamos de crear. Una vez en el escribimos:

    node servidor.js

El servidor arrancará y nos mostrará en el terminal el mensaje de log que indicamos en el programa. Si ahora abrimos un navegador y escribimos la siguiente dirección http://localhost:1333 tendríamos que ver por pantalla *Hola mundo*.

Como se puede ver con Node.js en muy pocos pasos tenemos montado un servidor que escucha nuestras peticiones. Actualmente no tiene mucha funcionalidad el ejemplo que hemos visto, pero en siguientes entradas iremos viendo como podemos crear poco a poco una aplicación completa.

Entradas relacionadas:

* [Gestión de rutas en Node.js](/2012/06/16/gestion-de-rutas-nodejs.html)
* [Plantillas en Node.js](/2012/07/12/plantillas-nodejs.html)
* [Conexión a base de datos con Node.js](/2012/08/28/conexion-base-datos-nodejs.html)