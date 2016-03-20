---
layout: post
comments: false
title: Silex y Twig
---

**Actualización Octubre 2012:** Con las últimas versiones de Silex el método para crear un proyecto con el fichero .phar a quedado obsoleto. Si quieres ver como crear un proyecto nuevo en Silex dale un vistazo a la entrada [Actualizada la forma de crear un proyecto en Silex](/2012/10/13/actualizada-forma-crear-proyecto-silex.html).

Después de haber realizado una pequeña [introducción a Silex](/2011/07/13/silex-micro-framework-php.html) y dedicarle dos entradas a Twig ([Plantillas Twig I](/2011/08/08/twig-plantillas-php-i.html) y [Plantillas Twig II](/2011/08/27/twig-plantillas-php-ii.html)), es ahora el turno de ver como podemos unir estas dos tecnologías para sacar más partido de ellas. Cada uno de estos componentes tendrá su función, mientras que Silex se encargará de llevar toda la lógica de nuestra aplicación, Twig será el encargado de mostrar los resultados en pantalla renderizando las plantillas que creemos.

Vamos como siempre a crear una pequeña aplicación para mostrar de forma práctica la forma de utilizar Silex junto a Twig. 

<!--more-->

Lo primero será crearnos un directorio para nuestra aplicación al que llamaremos **Software**, seguidamente descargaremos Silex desde su página de descarga y guardaremos el fichero **silex.phar** dentro de nuestro directorio. Para dejarlo todo listo necesitamos también descargar Twig, procedemos a hacerlo desde su página y lo almacenamos en el directorio de la aplicación dentro de una nueva carpeta que crearemos llamada **vendor**. También vamos a crear las siguientes carpetas dentro de la carpeta del proyecto: **views** que será donde almacenaremos las plantillas que creemos, **css** para poner nuestra hoja de estilos y **images** donde almacenaremos las imágenes usadas. De esta forma el directorio de trabajo nos quedará así:

```none
Software
|
| - vendor
    |
    | - twig
          |
          | + lib
| + views
|
| - css
| - images
|
| - index.php
| - silex.phar
| - .htdocs
```

Cuando tengamos todo nuestro directorio de trabajo listo, comenzaremos a configurar Silex. Lo primero que haremos será crear un fichero **.htaccess** para que todas las solicitudes a nuestra aplicación se redirijan al mismo fichero. En nuestro caso he decidido que todas las solicitudes se redirijan al fichero **index.php**. El código para el fichero **.htaccess** será el siguiente:

```none
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>
```

Ahora crearemos el fichero al que llegarán las solicitudes, **index.php**, en él tendremos la lógica de nuestra aplicación. Lo primero que tenemos que indicar es que vamos a utilizar la extensión de Twig y en sistema de enrutamiento de Silex, así que ponemos lo siguiente en el fichero:

``` php
<?php
require_once 'silex.phar';

$app = new Silex\Application();

$app->register(new Silex\Extension\UrlGeneratorExtension());
$app->register(new Silex\Extension\TwigExtension(), array(
                            'twig.path' => __DIR__ . '/views',
                            'twig.class_path' => __DIR__ . '/vendor/twig/lib'
));
```

El sistema de enrutamiento nos permite tener direcciones url limpias y sin los feos parámetros que se envían por GET. Mientras que Twig como ya sabemos nos ayuda a crear plantillas para mostrar la información al usuario. Como vemos en el código para registrar el sistema de enrutamiento simplemente tenemos que hacer una llamada a la función register indicando la extensión de enturamiento (linea 6) mientras que para registrar Twig además de indicar la extensión (linea 7), le diremos dónde está el directorio en el que tiene que buscar las plantillas (linea 8) y el directorio donde hemos descargado antes Twig (linea 9).


Una vez que tenemos configurado Twig ya podemos comenzar a programar, lo primero será crear una página de inicio. Para ello vamos a nuestro fichero **index.php** y añadimos al final del fichero lo siguiente:

``` php
<?php
$app->get('/', function() use($app) {
    return $app['twig']->render('index.twig.html');
})->bind('inicio');
```

Con este código estamos diciéndole a Silex que cuando reciba una petición por GET a la raiz del sitio ejecute la función indicada. Una solicitud GET es cuando escribimos una ruta en el navegador web o pinchamos un enlace, mientras que una solicitud POST se suele usar al enviar formularios e información. También podemos trabajar con solicitudes POST en Silex, simplemente tendremos que usar la función **post** en vez de **get**. Si nos fijamos en la función que queremos que se ejecute aparece al lado de su declaración lo siguiente **use ($app)** esto permite que dentro de la función se pueda usar la variable declarada fuera y que se llama **$app**. Esta variable **$app** es la que contiene todo el motor de Silex y la usaremos dentro de casi todas las funciones.

Dentro de la función a ejecutar, pondríamos toda la lógica necesaria, consultas a la base de datos, comprobaciones... En nuestro caso no vamos a realizar ninguna lógica y simplemente le diremos al motor de Twig que renderice la plantilla **index.twig.html** para ello utilizamos la variable **$app** y llamamos a la componente Twig y en ella a la función render para que renderice la plantilla **index.twig.html**

Por último, con lo que devuelve la llamada del método **$app->get()** se llama al método **bind** con el parámetro *inicio*. Esto hace que cuando utilicemos el sistema de enrutamiento simplemente tengamos que indicarle que queremos ir a *inicio* para que automáticamente nos cree una url correcta a este método.

Como aún no hemos creado ninguna plantilla vamos a ponernos a ello ahora, vamos a la carpeta **views** y creamos un nuevo fichero que llamaremos **layout.twig.html** con el siguiente contenido:

``` html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>{% raw %}{% block title %}Software{% endblock %}{% endraw %}</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link rel="stylesheet" href="css/general.css" />
</head>
<body>
    <div id="web">
        <h1>Software Gratuito</h1>
        <div id="menu">
            <ul>
                <li>
                    <a href="{% raw %}{{ app.url_generator.generate('inicio') }}{% endraw %}">
                        Inicio
                    </a>
                </li>
                <li>
                    <a href="{% raw %}{{ app.url_generator.generate('imagenes') }}{% endraw %}">
                        Imágenes
                    </a>
                </li>
                <li>
                    <a href="{% raw %}{{ app.url_generator.generate('texto') }}{% endraw %}">
                        Texto
                    </a>
                </li>
            </ul>
        </div>

        <h2>{% raw %}{% block tituloSeccion %}{% endblock %}{% endraw %}</h2>

        <div id="contenido">
            {% raw %}{% block contenido %}{% endraw %}
            {% raw %}{% endblock %}{% endraw %}
        </div>
    </div>
</body>
</html>
```

Si miramos como se han creado los enlaces para cada una de la sección de la página, vemos que se ha llamado a unas funciones para crearlos. Cuando Silex llama a Twig para que renderice una plantilla, Silex le pasa a Twig la variable que tiene toda la aplicación Silex que el usuario ha creado. En nuestro caso llamamos a esta variable **$app**, por eso ahora desde dentro de Twig tenemos una variable que se llama **app** (Twig no utiliza el símbolo $ para las variables, motivo por el cual desaparece el símbolo) y que podemos utilizar cuando la necesitemos. En este caso la utilizamos para llamar a la extensión de enturamiento **url_generator** y en ella llamamos al método **generate** pasando como parámetro el mismo nombre que indicamos dentro del fichero **index.php** al llamar al método **bind**. Aunque de momento solo hemos visto una ruta, yo ya he creado el enlace para las otras dos y posteriormente en el método **bind** las llamare con ese nombre.

Ahora que tenemos la plantilla base crearemos el fichero de la página principal, que como hemos dichos antes, llamaremos **index.twig.html**.

``` html
{% raw %}{% extends 'layout.twig.html' %}{% endraw %}

{% raw %}{% block tituloSeccion%}{% endraw %}
Bienvenido
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block contenido %}{% endraw %}
<p>
Bienvenido a nuestra página de software, en ella podrás encontrar software de 
utilidad que puedes usar en tu día a día de forma gratuita.
  ...
</p>

<p>
...
</p>
{% raw %}{% endblock %}{% endraw %}
```

Esta plantilla no contiene casi nada, simplemente un poco de información de la página y contenido para rellenar. A continuación volvemos al fichero **index.php** y vamos a crear la siguiente función justo debajo de lo que tenemos ahora.

``` php
<?php
$app->get('/imagenes', function() use ($app) {
    return $app['twig']->render('imagenes.twig.html');
})->bind('imagenes');
```

De nuevo como antes le indicamos a Silex que si la ruta que recibe es **imagenes** tiene que renderizar la plantilla **imagenes.twig.html**. Esta plantilla tiene el siguiente contenido:

``` html
{% raw %}{% extends 'layout.twig.html' %}{% endraw %}

{% raw %}{% block title %}{% endraw %}Imagenes - {% raw %}{{ parent() }}{% endblock %}{% endraw %} 

{% raw %}{% block tituloSeccion%}{% endraw %}
  Imagenes
{% raw %}{% endblock %}{% endraw %} 

{% raw %}{% block contenido %}{% endraw %}
  <div class="entrada">
    <h3>Gimp</h3>
    <img src="images/gimp.png" alt="Gimp" /> 
    <p>
      Es un programa que nos puede ayudar a realizar retoque fotográfico, 
      creación y edición de imagen. Gimp es muy usado para la  creación de 
      diseños web, gráficos para páginas webs asi como logotipos. Contiene 
      una gran cantidad de herramientas así como numerosos filtros para 
      añadir efecto a las imagenes.    
    </p>
  </div> 

  <div class="entrada"> 
    <h3>Inkscape</h3> 
    <img src="images/inkscape.jpg" alt="Inkscape" />
    <p> 
      Inkscape es un editor de gráficos vectoriales de código abierto. Las 
      características soportadas incluyen: formas, trazos, texto, marcadores, 
      clones,mezclas de canales alfa, transformaciones, gradientes, patrones 
      y agrupamientos. Inkscape también soporta meta-datos Creative Commons, 
      edición de nodos, capas, operaciones complejas con trazos, vectorización 
      de archivos gráficos, texto en trazos, alineación de textos, edición 
      de XML directo y mucho más.
    </p>
  </div>
{% raw %}{% endblock %}{% endraw %}
```

Seguimos con el fichero **index.php** y añadimos la última función:

``` php
<?php
$app->get('/ofimatica', function() use ($app) {
    return $app['twig']->render('ofimatica.twig.html');
})->bind('ofimatica');
```

Esta función renderiza la plantilla **ofimatica.twig.html** que tenemos que crear dentro del directorio de las plantillas con el siguiente codigo:

``` html
{% raw %}{% extends 'layout.twig.html' %}{% endraw %}

{% raw %}{% block title %}{% endraw %}Ofimática - {% raw %}{{ parent() }}{% endblock %}{% endraw %}

{% raw %}{% block tituloSeccion%}{% endraw %}
Texto
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block contenido %}{% endraw %}
<div class="entrada">
    <h3>Libre Office</h3>
    <img src="images/libreoffice.jpg" alt="Libre Office" />
    <p>
        LibreOffice es una suite ofimática multiplataforma, libre y gratuita. 
        Dispone de un procesador de texto (Writer), un editor de hojas de 
        cálculo (Calc), un creador de presentaciones (Impress), un gestor de 
        bases de datos(Base), un editor de gráficos vectoriales (Draw), y un
        editor de fórmulas matemáticas (Math).
    </p>
</div>

<div class="entrada">
    <h3>Open Office</h3>
    <img src="images/oo.png" alt="Open Office" />
    <p>
        Open Office es una suite ofimática libre (código abierto y 
        distribución gratuita) que incluye herramientas como procesador de 
        textos, hoja de cálculo, presentaciones, herramientas para el dibujo 
        vectorial y base de datos.4 Está disponible para varias plataformas, 
        tales como Microsoft Windows, GNU/Linux, BSD, Solaris y Mac OS X. 
        Soporta numerosos formatos de archivo, incluyendo como predeterminado 
        el formato estándar ISO/IEC OpenDocument (ODF), entre otros formatos 
        comunes.
    </p>
</div>
{% raw %}{% endblock %}{% endraw %}
```

Por último para que todo funcione correctamente en el fichero **index.php** al final del todo tenemos que añadir la siguiente línea:

``` php
<?php
$app->run();
```

El método **run** se encarga de ejecutar la aplicación, recuperar la solicitud que ha enviado el usuario y devolver la página que corresponda en cada caso.

Como hemos visto en muy pocos pasos hemos podido crear unas cuantas páginas web con ayuda de Silex y Twig. En siguientes entradas veremos como podemos pasarle parámetros a las plantillas para que los muestre al usuario y como interactuar con una base de datos.

Como siempre podéis descargar el ejemplo realizado desde [aquí](/uploads/posts/samples/Silex_y_Twig.rar).