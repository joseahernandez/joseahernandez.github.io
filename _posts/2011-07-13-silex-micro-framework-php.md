---
layout: post
comments: false
title: Silex, micro framework para PHP
---

**Actualización Octubre 2012:** Con las últimas versiones de Silex el método para crear un proyecto con el fichero .phar a quedado obsoleto. Si quieres ver como crear un proyecto nuevo en Silex dale un vistazo a la entrada [Actualizada la forma de crear un proyecto en Silex](/2012/10/13/actualizada-forma-crear-proyecto-silex.html).

Una de las charlas que más me llamó la atención de las [jornadas Symfony 2011](http://symfony.es/noticias/2011/07/06/desymfony-2011-todos-los-videos-y-presentaciones/) fue la que trataba sobre [Silex](http://silex.sensiolabs.org/). Por ello he decidido hacer una serie de posts en los que iré mostrando los pequeños pasos que voy aprendiendo sobre este micro framework.

Comencemos por el principio, Silex es un micro-framework para desarrollar aplicaciones y sitios web en PHP. Ha sido desarrollado por los mismos creadores que [Symfony](http://symfony.com), uno de los frameworks más importantes y más usados de PHP. Sabiendo esto nos puede surgir la siguiente pregunta: si ya tenían uno de los mejores frameworks, ¿por qué desarrollan otro? La respuesta es muy sencilla, como he mencionado antes, Silex es un micro-framework, lo que quiere decir que su objetivo es ser utilizado para desarrollar pequeñas aplicaciones que no requieran una extensa configuración y que no serán utilizadas por una gran cantidad de usuarios.

Aunque pueda parecer que Silex está muy limitado y que por ello solo se debe usar en aplicaciones pequeñas, la realidad es todo lo contrario. Silex permite que se le añada nueva funcionalidad gracias a extensiones que son muy sencillas de crear. Además cuenta con algunas extensiones muy útiles ya desarrolladas que se pueden usar fácilmente.

<!--more-->

En la entrada de hoy simplemente vamos a ver como crear un par de páginas sencillas para ir familiarizándonos con esta tecnología.

Lo primero que tenemos que hacer es [descargar Silex](http://silex.sensiolabs.org/download). Es un único fichero con extensión phar y que solamente ocupa 425 KB. Dentro de este fichero está incluido todo el framework, así que como podemos ver es muy ligero. A continuación vamos a crear dos ficheros que necesitamos para tener nuestra aplicación funcionando correctamente.

El primero es un fichero **.htaccess** para configurar apache. Normalmente todos los servidores apache aceptan este tipo de fichero y solamente necesitamos colocarlo en la carpeta de nuestro sitio. El contenido del fichero es el siguiente:

    <IfModule mod_rewrite.c>
        RewriteEngine On
        #RewriteBase /path/to/app
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ index.php [QSA,L]
    </IfModule>

Si cuando estemos probando la aplicación vemos que tenemos algún problema con las urls, es posible que tengamos que eliminar el comentario de la línea RewriteBase e indicar la ruta a nuestra carpeta para que todo funcione correctamente, aunque a mí así me ha funcionado bien.

El segundo fichero que vamos a crear lo llamaremos **index.php** y es donde escribiremos los controladores para todas nuestras acciones. Para comenzar escribimos lo siguiente:

{% highlight php linenos %}
<?php
  require_once 'silex.phar';

  $app = new Silex\\Application();

  // Aquí irá el código de los controladores

  $app->run();
?>
{% endhighlight  %}

En la primera línea incluimos el fichero de Silex que nos hemos descargado anteriormente. La segunda línea creamos un nuevo objeto de tipo Application y en la tercera línea lanzamos a ejecución la aplicación. De momento ya tenemos la configuración básica realizada, ahora vamos a escribir los controladores donde indica el comentario. Borramos la línea del comentario y escribimos lo siguiente:


{% highlight php linenos startinline=true %}
$app->get('/', function()  {
  
  return '<html><head><title>Aplicación de Ejemplo Silex</title></head>' .
            '<body><h1>Bienvenido</h1>' .
            '<form action="saludar" method="post">' .
            '<p>Indica tu nombre para continuar: ' .
            '<input type="text" name="nombre" /><br />' .
            '<input type="submit" value="Aceptar" />' .
            '</form></body></html>';
});
{% endhighlight  %}

En la primera línea utilizamos el método **get** del objeto Application para indicar que tiene que responder a las solicitudes que le lleguen mediante get a la ruta que indicamos en el primer argumento, en este caso **/** que es la ruta principal. Como segundo parámetro indicamos la función que queremos que se ejecute cuando se reciba esta petición.

En nuestro caso simplemente respondemos con un código html que genera un formulario con un campo. Vamos a crear ahora otro controlador.

{% highlight php linenos startinline=true %}
$app->post('/saludar', function() use($app) {

  return '<html><head><title>Aplicación de Ejemplo Silex</title></head>' .
            '<body><h1>Bienvenido</h1>' .
            '<p>Enhorabuena <strong>' . $app['request']->get('nombre') . 
            '</strong>, ya tienes tu primera aplicación con Silex.</p>' .
            '</body></html>';
});
{% endhighlight  %}

En esta ocasión esperamos una solicitud por **post** a la ruta **/saludar**. Como novedad, le indicamos a la función que vamos a hacer uso de la variable $app que es externa a la función, indicándolo con la sentencia **use($app)**. El código simplemente genera una pantalla en la que recuperamos el nombre del input con la sentencia **$app['request']->get('nombre')**.

Como hemos podido ver, de una forma sencilla hemos creado una pequeña funcionalidad para una página web aprovechándonos de las características que nos ofrece Silex. Aunque en un principio pueda parecer engorroso tener que escribir todo el código html en el controlador, podemos utilizar plantillas de forma que tengamos separado el código. En próximas entradas mostraré como utilizar el motor de plantillas [Twig](/2011/08/08/twig-plantillas-php-i.html) para generar el código html y tenerlo separado del controlador y como conectarnos a una base de datos.

Si os ha parecido interesante la entrada, os recomiendo que le deis un vistazo a la página del [proyecto Silex](http://silex.sensiolabs.org) donde explican como sacarle todo el partido al framework.