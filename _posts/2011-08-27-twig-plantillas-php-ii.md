---
layout: post
comments: false
title: Twig, plantillas para PHP (II)
---

En la entrada anterior hablé un poco sobre Twig y PHP, ahora toca concluir la entrada finalizando el proyecto de ejemplo que comenzamos a realizar. Comenzaremos modificando los ficheros que creamos para cada marca de teléfono y lo dejaremos de la siguiente forma:

``` php
<?php
    require_once 'Twig/Autoloader.php';
    Twig_Autoloader::register();
    $loader = new Twig_Loader_Filesystem('templates');

    $twig = new Twig_Environment($loader, array(
                 'cache' => 'cache',
                 'debug' => 'true'));

    $template = $twig->loadTemplate('stock.twig.html');

    $marca = 'Nokia';
    $moviles = array(
        array(
            'nombre' => 'Nokia 500',
            'imagen' => 'nokia500.png'
        ),
        array(
            'nombre' => 'Nokia C5 5MP',
            'imagen' => 'nokiac55mp.png'
        ),
        array(
            'nombre' => 'Nokia C2-01',
            'imagen' => 'nokiac201.png'
        ),
        array(
            'nombre' => 'Nokia c5-03',
            'imagen' => 'nokiac503.png'
        )
     );

    echo $template->render(array('marca' => $marca, 'moviles' => $moviles));
```

Como observamos las primeras líneas son idénticas a lo que teníamos hasta ahora. A partir de la line 12 es donde comenzamos a ver las cosas nuevas. En concreto tenemos la variable **$marca** que contiene el nombre de la marca y la variable **$moviles** que es un array que contiene arrays con el nombre del modelo de teléfono y una imagen de este. Estos datos los podríamos haber obtenido de cualquier fuente de datos, una base de datos, un fichero, un servicio web. Pero para clarificar el ejemplo he decidido hacerlo así. La &uacute;ltima line que vemos es la llamada al método **render** en ella, en esta ocasión en vez de pasarle un array vacío pasamos un array asociativo indicando un nombre y la variable que queremos que contenga. El nombre en el array asociativo es muy importante, ya que, posteriormente desde twig para acceder a las variables tendremos que usar el nombre que hemos indicado en el array asociativo.

<!--more-->

El resto de ficheros de cada marca de teléfono contiene lo mismo pero cambiando sus datos. Se puede ver si descargáis el fichero (al final de la entrada).

Ahora es el turno de trabajar un poco sobre la plantilla **stock.twig.html** y de ver nuevos elementos que nos proporciona Twig. Vamos a dejar la plantilla de la siguiente forma:

``` html
{% raw %}{% extends "layout.twig.html" %}{% endraw %}

{% raw %}{% block title %}{{ marca }} | {{ parent() }} {% endblock %}{% endraw %}

{% raw %}{% block subtitulo %}{% endraw %}
 Moviles {% raw %}{{ marca }}{% endraw %}
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block contenido %}{% endraw %}
 <ul>
  {% raw %}{% for m in moviles %}{% endraw %}
   <li>
    {% raw %}{{ m.nombre }}{% endraw %}
    <br />
    <a href="images/{% raw %}{{ m.imagen }}{% endraw %}">
     <img src="images/{% raw %}{{ m.imagen }}{% endraw %}" alt="{% raw %}{{ m.nombre }}{% endraw %}" class="imagen" />
    </a>
   </li>
  {% raw %}{% endfor %}{% endraw %}
 </ul>
{% raw %}{% endblock %}{% endraw %}
```

El código anterior es similar al que vimos en la entrada anterior, pero hemos a&ntilde;adido nuevas características. En el bloque **title** hemos a&ntilde;adido lo siguiente: **{% raw %}{{ marca }}{% endraw %}**, el uso de las doble llaves ({% raw %}{{ }}{% endraw %}) indica a Twig que lo que hay entre ellas es una variable que se le ha pasado a la plantilla. Esta variable es la que pasamos con el método **render** y cuyo nombre **marca** indicamos en el array asociativo.

Más adelante tenemos una instrucción for entre las llaves {% raw %}{% y %}{% endraw %}; *for m in moviles*. La instrucción for, recorre los elementos de un array, en este caso **moviles** y los va asignando uno a uno a la variable indicada, **m**. Dentro de este bucle vamos usando la variable **m** para consultar el nombre y la imagen. Al llegar a la sentencia **m.nombre** Twig realiza la siguiente búsqueda para encontrar el valor:

* Se comprueba si m es un array y si nombre es una componente del array.
* Si no, se comprueba si m es un objeto y nombre es una propiedad.
* Si no, se mira si m es un objeto y nombre es un método.
* Si no, se mira si m es un objeto y existe un método llamado getNombre.
* Si no, se mira si m es un objeto y existe un método llamado isNombre.
* Por último si no se encuentra ninguna opción se devuelve null.

En nuestro caso como en el código php le pasamos un array ejecutaría la primera opción y mostraría la componente del array llamada nombre. También ocurre lo mismo con la sentencia **m. imagen**. Para finalizar el bucle lo indicamos con la etiqueta **{% raw %}{% endfor %}{% endraw %}**

Hay que indicar que para que esto funcione correctamente tenemos que tener en nuestro directorio de trabajo una carpeta llamada images que contiene las imágenes para cada uno de los elementos que indicamos.

Si recordamos la entrada anterior, indiqué que había generado un fichero para cada marca para poder ver como desde varias páginas podríamos reutilizar la misma plantilla. Ahora lo que voy a hacer es reorganizar mejor el ejemplo y dejarlo todo más compacto. Para comenzar modificaremos la plantilla **layout.twig.html** y donde teníamos el men&uacute; vamos a sustituir los enlaces por lo siguiente:

``` html
<div class="menu">
    <ul>
        <li><a href="index.php">Inicio</a></li>
        <li><a href="marcas.php?marca=nokia">Nokia</a></li>
        <li><a href="marcas.php?marca=samsung">Samsung</a></li>
        <li><a href="marcas.php?marca=htc">HTC</a></li>
        <li><a href="marcas.php?marca=alcatel">Alcatel</a></li>
    </ul>
</div>
```

Seguidamente creamos un nuevo fichero que llamaremos **marcas.php** y en el ponemos lo siguiente:

``` php
<?php
    require_once 'Twig/Autoloader.php';
    Twig_Autoloader::register();

    $loader = new Twig_Loader_Filesystem('templates');
    $twig = new Twig_Environment($loader, array(
                'cache' => 'cache',
                'debug' => 'true'));
    $template = $twig->loadTemplate('stock.twig.html');

    $datos = array(
        'nokia' => array(
            array(
                'nombre' => 'Nokia 500',
                'imagen' => 'nokia500.png'
            ),
            array(
                'nombre' => 'Nokia C5 5MP',
                'imagen' => 'nokiac55mp.png'
            ),
            array(
                'nombre' => 'Nokia C2-01',
                'imagen' => 'nokiac201.png'
            ),
            array(
                'nombre' => 'Nokia c5-03',
                'imagen' => 'nokiac503.png'
            )
        ),
        'samsung' => array(
            array(
                'nombre' => 'Omnia 7',
                'imagen' => 'omnia7.jpg'
            ),
            array(
                'nombre' => 'Galaxy S2',
                'imagen' => 'galaxys2.jpg'
            ),
            array(
                'nombre' => 'Galaxy Pro',
                'imagen' => 'galaxypro.jpg'
            ),
            array(
                'nombre' => 'Wave 533',
                'imagen' => 'wave533.jpg'
            )
        ),
        'htc' => array(
            array(
                'nombre' => 'HD 7',
                'imagen' => 'hd7.jpg'
            ),
            array(
                'nombre' => 'Cha Cha Cha',
                'imagen' => 'chachacha.jpg'
            ),
            array(
                'nombre' => 'Sensation',
                'imagen' => 'sensation.jpg'
            ),
            array(
                'nombre' => 'Salsa',
                'imagen' => 'salsa.jpg'
            )
        ),
        'alcatel' => array(
            array(
                'nombre' => 'OT 800',
                'imagen' => 'OT800.jpg'
            ),
            array(
                'nombre' => 'OT 660',
                'imagen' => 'OT660.jpg'
            ),
            array(
                'nombre' => 'OT 708',
                'imagen' => 'OT708.jpg'
            ),
            array(
                'nombre' => 'Mandarina Duck Moon',
                'imagen' => 'MandarinaDuckMOON.jpg'
            )
        )
    );

    if( isset($_GET['marca']) ) {
        $moviles = $datos[$_GET['marca']];

        if( count($moviles) == 0 )
            header('Location: index.php');
        else
            echo $template->render(array('marca' => $_GET['marca'], 'moviles' => $moviles));
    }
    else
        header('Location: index.php');
```

Tenemos todos los datos almacenados en un array y hacemos que por un parámetro GET nos pasen la marca. Si existe ese parámetro cuando se llama a la página **marcas.php** y además el array que contiene los datos tiene esa clave se llama a la función **render** pasándole el array de datos y la marca. En cualquier otro caso realizamos una redirección a la página de inicio.

Para finalizar la entrada, quería comentar unas cuantas cosas sobre Twig. En general podemos identificar tres tipos de etiquetas en Twig:

* {% raw %}{{ }}{% endraw %} nos sirve para mostrar variables
* {% raw %}{% %}{% endraw %} sirve para indicar instrucciones: for, if, block, extends...
* {% raw %}{# #}{% endraw %} sirve para poner comentarios dentro de las plantillas.

Con las etiquetas **{% raw %}{{ }}{% endraw %}** además de mostrar las variables que pasemos, también podemos aplicarles algunos filtros como por ejemplo **{% raw %}{{  marca \| upper}}{% endraw %}** que haría que el contenido de la variable marca apareciera en mayúsculas. Todas estas características las podemos encontrar muy bien explicadas en la [documentación de Twig](http://www.twig-project.org/doc/templates.html).

Aquí dejo los enlaces para los dos ejemplos: [Ejemplo con varios ficheros](/uploads/posts/samples/twigSample-completo.rar) y [Ejemplo con un fichero](/uploads/posts/samples/twigSample-reducido.rar).

Si queréis acceder a la primera parte de la entrada podéis acceder desde aquí: [Twig, plantillas para PHP (I)](/2011/08/08/twig-plantillas-php-i.html)