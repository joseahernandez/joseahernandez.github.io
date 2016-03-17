---
layout: post
comments: false
title: Twig, plantillas para PHP (I)
---

Twig es un motor de plantillas para PHP que destaca por su facilidad para usarlo y por su clara sintaxis que permite que se comprenda a la perfección por cualquier persona aunque no sea un desarrollador. Al igual que en la entrada anterior en la que hablaba sobre [Silex](/2011/07/13/silex-micro-framework-php.md), Twig es la otra herramienta que más llamó mi atención en las jornadas Symfony 2011. 


Voy a realizar un pequeño ejemplo donde podremos ver algunas de las características con las que cuenta Twig. Para comenzar tenemos que descargarnos Twig. Vamos a la [sección de instalación](http://www.twig-project.org/installation) de su página y tenemos varias opciones para descargar: un fichero .zip o .tar, descargar a partir del repositorio Git y descargar mediante PEAR. En este caso voy a optar por descargar el fichero zip y lo guardaré dentro de la carpeta que he creado para el proyecto, **ejemploTwig**.

<!--more-->

Al descomprimir el fichero vemos que contiene diversas carpetas y ficheros con documentación, pruebas, licencia... a nosotros nos interesa la carpeta llamada **Twig** que se encuentra dentro de la carpeta **lib**. Copiamos esa carpeta **Twig** y la pegamos dentro de nuestra carpeta del proyecto.

A continuación, en la carpeta del proyecto vamos a crear dos nuevas carpetas, una la llamaremos **templates** y otra **cache**. En la carpeta **templates** guardaremos las plantillas Twig que creemos para nuestro proyecto. Por su parte, en la carpeta **cache** se almacenarán las plantillas renderizadas en php para poder servirlas de forma más rápida y eficiente.

Lo siguiente será crearnos un fichero que llamaremos **index.php** desde donde realizaremos la lógica y posteriormente llamaremos a las plantillas Twig. Dentro de este fichero en un principio pondremos lo siguiente:

{% highlight php linenos %}
<?php
  require_once  'Twig/Autoloader.php ';

  Twig_Autoloader::register();
  $loader = new Twig_Loader_Filesystem( 'templates ');
  $twig = new Twig_Environment($loader, array(
         'cache ' = >  'cache ',
         'debug ' = >  'true '
)); 
{% endhighlight %}

En la segunda línea se incluye el autoloader para que podamos utilizar todo el motor de Twig. En la cuarta línea registramos Twig y a partir de aquí comenzamos a configurarlo. En la línea cinco creamos un objeto loader indicando cual es el directorio donde estarán almacenadas las plantillas. En este caso hemos dicho que el directorio será **templates**. En la sexta línea nos creamos un objeto Twig que será el que usaremos para renderizar las plantillas, a este objeto tenemos que pasarle el loader que nos hemos creado antes y un array con distintas opciones. En este caso le indicamos la carpeta donde se tienen que almacenar las plantillas en cache y también indicamos que estamos en modo debug para que genere las plantillas de nuevo cada vez. Si no pusiéramos la opción debug, cada vez que realizáramos una modificación en una plantilla tendríamos que borrar todo el contenido del directorio cache. Cuando pasemos la aplicación a producción pondríamos la opción debug a false para que las guarde una vez en cache y posteriormente las sirva más rápido.

Ahora vamos a trabajar un poco con las plantillas de Twig. Si has desarrollado alguna web, seguro que sabes que normalmente todas las páginas de un sitio siguen un mismo diseño, misma cabecera, mismo menú y mismo pie. Pues para ello nos vamos a crear una plantilla que contendrá estos apartados y de la que heredaran el resto de plantillas. Vamos a la carpeta **template** y creamos un nuevo fichero que llamaremos **layout.twig.html**. En él ponemos lo siguiente:

{% highlight html linenos %}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" >
<html xmlns="http://www.w3.org/1999/xhtml">  
  <head> 
    <title>{% raw %}{% block title %}Utilizando Twig{% endblock %}{% endraw %}</title>
    <meta charset="utf-8"> 
  </head> 
  <body> 
    <h1>Bienvenido a Twig</h1> 
    <h2>{% raw %}{% block subtitulo %}{% endblock %}{% endraw %}</h2> 

    <div>
      {% raw %}{% block contenido %}
      {% endblock %}{% endraw %}
    </div> 
  <body> 
</html>
{% endhighlight %}

Como vemos es un documento html en el cual tenemos la estructura básica de nuestra página. Pero si nos fijamos, aparecen unas etiquetas que no pertenecen a html, si no a Twig. Estas etiquetas se abren con **{% raw %}{% block nombre %}{% endraw %}**, donde *nombre* es el nombre que nosotros queramos ponerle al bloque de la plantilla. La forma de cerrarla es **{% raw %}{% endblock %}{% endraw %}**. Con estas etiquetas estamos definiendo bloques donde posteriormente insertaremos información mientras mantendremos el resto de la página con el mismo aspecto. Como se ve, podemos definir bloques en cualquier parte del documento html. Además podemos insertar texto o etiquetas html dentro de los bloques para que aparezca ese texto en caso de que posteriormente en otra plantilla no indiquemos el contenido de ese bloque, como es el caso con el bloque *title*.

Veamos otra plantilla que usará la que hemos creado anteriormente como estructura y rellenará el contenido de los bloques. Dentro de la carpeta **templates** creamos un nuevo fichero que llamaremos **index.twig.html**

{% highlight html linenos %}
{% raw %}{% extends "layout.twig.html" %}{% endraw %}

{% raw %}{% block subtitulo %}{% endraw %}
  Página principal
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block contenido %}{% endraw %}
  <p>
    Esta es la página principal de nuestra
  </p>
{% raw %}{% endblock %}{% endraw %}
{% endhighlight %}

La primera línea indica que esta plantilla va a utilizar como plantilla base **layout.twig.html**. La línea 3 indica que dentro del bloque que en la plantilla **layout.twig.html** hemos llamado subtítulo vamos a insertar el código o texto que incluimos ahora entre las etiquetas de apertura y cierre, *Página principal* en este caso. La línea 7 realiza lo mismo que la línea 3, pero en esta ocasión el código que hay entre las etiquetas se insertará en lo que en la plantilla base hemos declarado como bloque contenido. Es bastante sencillo ¿no?

En este momento solo nos falta mostrar la plantilla que acabamos de crear cuando sea necesario. Para ello volvemos al fichero **index.php** y al final de él ponemos el siguiente código:

{% highlight php linenos startinline=true %}
$template = $twig->loadTemplate('index.twig.html');
echo $template->render(array());
{% endhighlight %}

La línea uno declara la plantilla que vamos a usar para mostrar la información y la línea 2 renderiza la plantilla y la muestra al usuario. Como vemos en el método **render** le pasamos un array vacío como parámetro. Esto es porque en ese array podemos pasarle variables a la vista para que muestre distintos datos. Lo explicaré más detalladamente en otra entrada.

De una forma sencilla y fácil hemos declarado dos plantillas y las hemos utilizado para mostrar la información al usuario. Con estos pasos, hemos conseguido separar la lógica de la aplicación, que en este caso se encontrará en nuestro fichero **index.php**, de la presentación que está contenida en las plantillas. Lo cual es una buena práctica que posteriormente nos puede facilitar el mantenimiento.

Pero el uso de las plantillas no acaba aquí, ya que nos ofrecen un montón de posibilidades. De momento vamos a ver alguna cosa nueva y dejaremos preparado el proyecto para la segunda entrada sobre Twig donde veremos más características. Modificamos la plantilla **layout.twig.html** para añadir un menú y poder navegar por diferentes páginas. Además vamos a poner algo de información con más sentido para que sea un ejemplo algo más real. Dejaremos esta plantilla de esta forma:

{% highlight html linenos %}
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"> 
  <head>
    <title>{% raw %}{% block title %}Moviles para Todos{% endblock %}{% endraw %}</title>
    <meta charset="utf8" />
    <link href="css/estilos.css" rel="stylesheet" />
  </head>
  <body>
    <h1>Moviles para Todos</h1>
    
    <div class="menu">
      <ul>
        <li><a href="index.php">Inicio</a></li>
        <li><a href="nokia.php">Nokia</a></li>
        <li><a href="samsung.php">Samsung</a></li>
        <li><a href="htc.php">HTC</a></li>
        <li><a href="alcatel.php">Alcatel</a></li>
      </ul>
    </div>
    
    <h2>{% raw %}{% block subtitulo %}{% endblock %}{% endraw %}</h2>
    
    <div>
      {% raw %}{% block contenido %}
      {% endblock %}{% endraw %}
    </div>
  <body>
</html>
{% endhighlight %}

He utilizado una hoja de estilos para hacerle un pequeño diseño, la css se puede descargar junto a todo el proyecto al final de la entrada. Además le he añadido un menú con el cual navegaremos a través del resto de páginas que vamos a crear. Al incluir el menú en la plantilla de la que el resto de plantillas heredan, ese menú aparecerá en todas nuestras páginas. De forma que si es necesario realizar un cambio simplemente modificándolo en esta plantilla se reflejaría en el resto de la aplicación.

Seguidamente vamos a crear una nueva plantilla que utilizaremos para mostrar todos los productos que disponemos. Esta plantilla se llamara **stock.twig.html** y su código será el siguiente:

{% highlight html linenos %}
{% raw %}{% extends "layout.twig.html" %}{% endraw %}

{% raw %}{% block title %}Marca | {{ parent() }} {% endblock %}{% endraw %}

{% raw %}{% block subtitulo %}{% endraw %}
  Moviles
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block contenido %}{% endraw %}
    <p>Aquí tendremos la información de nuestros moviles</p>
{% raw %}{% endblock %}{% endraw %}
{% endhighlight %}

El código es el mismo que le que el que hemos visto antes pero variando los datos. Además vemos que hemos añadido el block **title** donde podemos ponerle el título de la marca a la página. Si nos damos cuenta, dentro del bloque **title** y después de poner el texto *Marca* utilizamos la instrucción **{% raw %}{{ parent() }}{% endraw %}**. Esta instrucción, lo que hace es buscar en las plantillas padres el contenido que tenían en ese bloque y ponerlo a la hora de renderizar la página. De esta forma lo que hemos puesto en la plantilla **layout.twig.html** también se mostrará cada vez que se renderiza la plantilla **stock.twig.html**.

Para ir acabando la entrada de hoy vamos a crearnos un fichero php por cada entrada del menú en la raíz de nuestro proyecto, así que tendremos los ficheros: **nokia.php**, **samsung.php**, **htc.php** y **alcatel.php**. De momento en todos ellos pondremos el siguiente contenido para que renderice la plantilla que acabamos de crear:

{% highlight php linenos startinline=true %}
require_once  'Twig/Autoloader.php ';

Twig_Autoloader::register();

$loader = new Twig_Loader_Filesystem('templates');

$twig = new Twig_Environment($loader, array(
             'cache' => 'cache',
             'debug' => 'true'));
            
$template = $twig->loadTemplate('stock.twig.html');

echo $template->render(array());
{% endhighlight %}

Antes de terminar quiero comentar una cosas, en vez de crearnos un archivo php también habría sido posible, y más certero, crear un único fichero y pasar un parámetro según qué entrada del menú se pulse, pero para mostrar que con una única plantilla podemos darle mucha utilidad he preferido hacerlo así.

Por último solo decir que en la próxima entrada mostraré como pasarle información a la plantilla para que muestre distintos datos. Si tenéis curiosidad os diré que simplemente hace falta mirar un poco el método **render**.

Para obtener el código del ejemplo podéis hacer clic [aquí](/uploads/posts/samples/twigSample1.zip).

Si queréis acceder a la segunda parte de la entrada podéis acceder desde aquí: [Twig, plantillas para PHP (II)](/2011/08/27/twig-plantillas-php-ii.html)