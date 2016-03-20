---
layout: post
comments: false
title: Silex, Doctrine y Twig I
---

**Actualización Octubre 2012:** Con las últimas versiones de Silex el método para crear un proyecto con el fichero .phar a quedado obsoleto. Si quieres ver como crear un proyecto nuevo en Silex dale un vistazo a la entrada [Actualizada la forma de crear un proyecto en Silex](/2012/10/13/actualizada-forma-crear-proyecto-silex.html).

Continuando sobre la serie de entradas sobre Silex, ahora es el turno para ver como integramos todo lo que hemos visto hasta el momento con una base de datos. En entradas anteriores hemos visto [como trabajar con Silex](/2011/07/13/silex-micro-framework-php.html) y [como usar plantillas Twig en Silex](/2011/09/10/silex-twig.html). A continuación vamos a juntar esto recuperando datos de una base de datos.


Comenzamos preparando nuestro directorio de trabajo, creamos una carpeta que llamaremos *Software* en nuestro servidor. En ella [descargamos Silex](http://silex.sensiolabs.org) dejando el fichero descargado **Silex.phar** en el directorio que hemos creado. A continuación creamos dentro de la carpeta *Software* una nueva carpeta que llamaremos *vendor*. Descargamos la última versión estable de [Twig](https://github.com/fabpot/Twig/tags), descomprimimos el fichero descargado y accedemos a la carpeta *lib* que se ha extraído. Dentro de ella, copiamos la carpeta llamada *twig* y la pegamos en la carpeta *vendor* que hemos creado antes. Después de esto, descargamos la última versión del [DBAL de Doctrine](http://www.doctrine-project.org/projects/dbal), descomprimimos el fichero descargado y copiamos la carpeta llamada *Doctrine* dentro de nuestro directorio *vendor*. Con esto ya tenemos todo lo necesario para ponernos a trabajar.

<!--more-->

Vamos a crear un fichero en la carpeta *Software* y le pondremos de nombre **.htaccess**. La función de este fichero será redirigir todas las peticiones al fichero index.php que crearemos a continuación. El contenido de **.htaccess** es el siguiente:

``` none
<ifmodule mod_rewrite.c="">
    RewriteEngine On
    RewriteBase /software
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php [QSA,L]
</ifmodule>
```

Hay que mencionar que en este fichero he insertado la línea **RewriteBase** porque la carpeta donde voy a guardar el proyecto no es la carpeta raíz de mi sitio. Es decir, para acceder al proyecto escribiré en mi navegador *https://localhost/software* si por el contrario estas creando el proyecto apuntando a la carpeta raíz de tu sitio esa línea se debe eliminar.

Como hemos mencionado antes ahora es el turno de crear el fichero **index.php**. En este fichero configuraremos tanto Twig como Doctrine para trabajar con ellos y daremos respuesta a las peticiones que se generen. De momento en el fichero pondremos el siguiente código:

``` php
<?php
require_once 'silex.phar';

$app = new Silex\Application();

$app['debug'] = true;

$app->register(new Silex\Provider\UrlGeneratorServiceProvider());

$app->register(new Silex\Provider\TwigServiceProvider(), array(
    'twig.path' => __DIR__ . '/views',
    'twig.class_path' => __DIR__ . '/vendor'
));

$app->register(new Silex\Provider\DoctrineServiceProvider(), array(
    'db.options' => array(
        'driver'   => 'pdo_mysql',
        'host'     => 'localhost',
        'dbname'   => 'software',
        'user'     => 'root',
        'password' => null,
    ),
    'db.dbal.class_path'  => __DIR__.'/vendor',
    'db.common.class_path' => __DIR__.'/vendor',
));

$app['db']->setCharset('utf8');

// Aqui iran las respuestas a las peticiones

$app->run();
```

En la línea 4 creamos la aplicación Silex. Seguidamente, en la línea 6 nos ponemos en modo debug para indicar que estamos desarrollando la aplicación y que se nos muestre si hay algún error. Cuando pongamos esta aplicación en producción pondremos el modo debug a false. A continuación, en la línea 8 registramos el generador de url. Entre las líneas 10 y 13 registramos Twig, indicamos donde guardaremos las vistas, en este caso crearemos una nueva carpeta que llamaremos *views* dentro de la carpeta *software*. También indicamos donde se encuentra la librería de twig. Entre las líneas 15 y 25 registramos doctrine. Dentro del array **db.options** tenemos que indicar el driver (en este caso usaremos una base de datos mysql por eso usamos el driver pdo_mysql), el host donde está la base de datos, el nombre de la base de datos, el usuario y la contraseña. En el array **db .dbal.class_path** indicaremos la ruta donde hemos guardado las librerías del DBAL de Doctrine y finalmente dentro del array **db.common.class_path** indicaremos la ruta donde están las librerías Common de Doctrine. Con la línea 27 indicamos que las conexiones con la base de datos serán en formato utf8 y para terminar en la línea 31 ponemos en marcha la aplicación.

A continuación vamos a diseñar nuestra base de datos para poder recuperar algunos datos. Vamos a tener una única tabla que se va a llamar *Software*. Esta tabla tendrá tres campos un identificador (id), el nombre y la descripción. Cuando tengamos la tabla creada añadiremos algunos datos para poder trabajar con ellos. Dejo un enlace con las [sentencias sql](/uploads/posts/samples/software.sql) que he utilizado tanto para crear la tabla como para rellenar algunos datos de prueba.

Vamos a crear ahora la respuesta cuando se solicite la primera página de nuestra aplicación, para ello en el fichero **index.php** justo debajo del comentario *Aquí irán las respuestas a las peticiones* añadimos lo siguiente:

``` php
<?php
$app->get('/', function() use ($app) {
    $sql = 'SELECT nombre, descripcion FROM software';
    $software = $app['db']->fetchAll($sql, array());

 return $app['twig']->render('inicio.twig.html', 
    array('software' => $software)
  );
})->bind('inicio');
```

En la primera línea estamos indicando que todas las peticiones de tipo GET que vayan a la raíz de nuestro sitio (lo indicamos pasando como primer argumento de la función get la /) van a ejecutar la siguiente función. En la función creamos una select que nos recupere todos los elementos de nuestra tabla y llamamos al método **fetchAll** de Doctrine. Silex nos almacena dentro de *$app['db']* un objeto Doctrine con el cual podemos realizar este tipo de consultas. Finalmente llamamos al objeto twig que Silex nos ha creado en *$app['twig']* y le decimos que renderice la plantilla inicio pasándole el array con todos los elementos recuperados de la base de datos.

La plantilla que muestra los elementos es la siguiente:

``` php
<?php
{% raw %}{% extends "layout.twig.html" %}{% endraw %}

{% raw %}{% block content %}{% endraw %}
 <table border="0" cellspacing="0" cellpadding="0">
  <thead>
   <tr>
    <th>Nombre</th>
    <th>Descripción</th>
    <th></th>
   </tr>
  </thead>
  <tbody>
   {% raw %}{% for s in software %}{% endraw %}
    <tr>
     <td>{% raw %}{{ s.nombre }}{% endraw %}</td>
     <td>{% raw %}{{ s.descripcion }}{% endraw %}</td>
     <td>
      <a href="{% raw %}{{ app.url_generator.generate('editar', {'id': s.id}) }}{% endraw %}">
        Editar
      </a>
      <a href="{% raw %}{{ app.url_generator.generate('eliminar', {'id': s.id}) }}{% endraw %}">
        Eliminar
      </a>
     </td>
    </tr>
   {% raw %}{% endfor %}{% endraw %}
  </tbody>
 </table>
{% raw %}{% endblock %}{% endraw %}
```

No creo que necesite mucha explicación ya que únicamente recorre el array que le hemos pasado y genera una tabla. Lo único que merece mención es la forma de crear los enlaces para editar y eliminar elementos. Cuando trabajamos con Silex y Twig, todas las plantillas de Twig tienen una variable llamada app que hace referencia al objeto de la aplicación. En nuestro caso hace referencia al mismo objeto que la variable $app en nuestro código php. Por lo tanto podemos utilizar el generador de url que hemos registrado anteriormente en el fichero **index.php**.

La forma de generar una url desde código php seria la siguiente:

``` php
<?php
$app['url_generator']->generate('editar', array('id' => 1));
```

Pero como estamos trabajando desde la plantilla, tenemos que usar la sintaxis de Twig. Como hemos mencionado en algún artículo anterior, cada vez que en Twig ponemos una variable seguida de un punto y de otra componente, Twig realiza varias comprobaciones para intentar obtener el valor:

* Se comprueba si la variable es un array y lo que viene a continuación del punto es una componente de este.
* Se comprueba si la variable es un objeto y lo que viene a continuación es una propiedad.
* Se comprueba si la variable es un objeto y lo que viene a continuación es un método.
* Se comprueba si la variable es un objeto y lo que viene a continuación es algún método precedido por get.
* Se comprueba si la variable es un objeto y lo que viene a continuación es algún método precedido por is.

En nuestro caso se utilizará la primera comprobación para indicar que *url_generator* es una componente del array *app* y posteriormente se utilizará la tercera comprobación para indicar que *generate* es un método del objeto *UrlGeneratorServiceProvider*. A continuación le indicaremos hacia que método queremos que nos genere la url indicando la misma cadena que le pondremos en la llamada al método **bind** del método a utilizar. Finalmente tenemos que pasar un array con los valores necesarios para la ruta. Para hacer esto en Twig utilizaremos la sintaxis **{'clave': 'valor'}**. En caso de tener que pasar más de un parámetro la sintaxis será **{'clave1': 'valor1', 'clave2': 'valor2'}**. Con esto tenemos que la llamada anterior al método *generate* en Twig nos quedará de la siguiente forma:

``` none
{% raw %}{{ app.url_generator.generate('editar', {'id': 1}) }}{% endraw %}
```

La plantilla inicio.twig.html extiende a la plantilla layout.twig.html cuyo contenido es el siguiente:

``` html
<!DOCTYPE html>
<html>
 <head>
  <title>Software</title>
  <link href="estilos.css" rel="stylesheet" type="text/css" />
  <base href="http://localhost/software/"  />
 </head>
 <body>
  <ul>
   <li><a href="{% raw %}{{ app.url_generator.generate('inicio') }}{% endraw %}">Listar</a></li>
   <li><a href="{% raw %}{{ app.url_generator.generate('insertar') }}{% endraw %}">Insertar</a></li>
  </ul>
  <div id="contenido">
   {% raw %}{% block content %}{% endraw %}
   {% raw %}{% endblock %}{% endraw %}
  </div>
 </body>
</html>
```

Para finalizar esta entrada vamos a volver al fichero **index.php** y antes de la llamada a **$app->run();** añadiremos el siguiente código:

``` php
<?php
$app->get('/insertar', function() use ($app) {
    return '';
})->bind('insertar');

$app->get('/editar/{id}', function($id) use ($app) {
    return '';
})->bind('editar');

$app->get('/eliminar/{id}', function($id) use ($app) {
    return '';
})->bind('eliminar');
```

Con este código crearemos todos los métodos que necesitaremos para que nuestro proyecto pueda ejecutarse correctamente y sin ningún error. En una próxima entrada completaremos el código de estos métodos. Si quieres descargar el código de este ejemplo puedes hacerlo desde [aquí](/uploads/posts/samples/silex-doctrine-twig-I.rar).

Si quieres acceder a la segunda parte del tutorial pincha en el siguiente enlace: [Silex, Doctrine y Twig II](/2012/02/01/silex-doctrine-twig-ii.html)