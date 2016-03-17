---
layout: post
comments: false
title: Silex, Doctrine y Twig II
---

**Actualización Octubre 2012:** Con las últimas versiones de Silex el método para crear un proyecto con el fichero .phar a quedado obsoleto. Si quieres ver como crear un proyecto nuevo en Silex dale un vistazo a la entrada [Actualizada la forma de crear un proyecto en Silex](/2012/10/13/actualizada-forma-crear-proyecto-silex.html).

Continuando con la entrada anterior sobre [Silex, Doctrine y Twig I](/2012/01/14/silex-doctrine-twig-i.html) ahora vamos a terminar de implementar los métodos que nos dejamos a medias la otra vez. Comenzaremos con el método más fácil de los tres que es el de eliminar. Lo primero que tenemos que hacer es en el fichero **index.php** justo después de la línea donde indicábamos que estamos en modo debug es registrar el modulo de sesión ya que lo usaremos para pasarnos mensajes cuando eliminemos, insertemos o actualicemos un elemento.

{% highlight php linenos startinline=true %}
$app = new Silex\\Application();

$app['debug'] = true;

$app->register(new Silex\\Provider\\SessionServiceProvider());
$app->register(new Silex\\Provider\\UrlGeneratorServiceProvider());

...
{% endhighlight %}

A continuación implementaremos el método eliminar. Este método recibirá un id del elemento a eliminar y lo borrará de la base de datos. El código que realiza esta funcionalidad es el siguiente:

<!--more-->

{% highlight php linenos startinline=true %}
$app->get('/eliminar/{id}', function($id) use ($app) {

    $rows = $app['db']->delete('software', array('id' => $id));

    if( $rows <= 0 )
        $app['session']->setFlash('error', 
            'Se ha producido un error al eliminar la fila seleccionada');
    else
        $app['session']->setFlash('ok', 
            'La fila ha sido eliminada correctamente');

    return $app->redirect($app['url_generator']->generate('inicio'));
})->bind('eliminar');
{% endhighlight %}

Para eliminar un elemento usaremos la variable **$app['db']** en la cual tenemos toda la funcionalidad que nos proporciona Doctrine. En esta página de la [documentación de Doctrine](http://www.doctrine-project.org/projects/dbal/2.1/api) tenemos todas las funciones que podemos utilizar. Como se puede ver fácilmente, el método **delete** recibe como primer parámetro la tabla donde se va a proceder a borrar y como segundo parámetro un array con las condiciones (la clausura where en lenguaje sql). Almacenamos en la variable **$row** el número de filas afectadas. Si es menor o igual a 0 significa que se ha producido un error, por eso utilizando el modulo de sesión se almacena un flash indicando el error que se ha producido. Si por el contrario se elimina alguna fila también almacenamos un flash pero con un mensaje de éxito.

Un flash no es ni mas ni menos que almacenar en sesión una variable pero con la peculiaridad de que una vez que se envíe la información al cliente esa variable será eliminada. Por eso es ideal para mostrar este tipo de mensajes.

Para finalizar con el método de eliminar, usamos método **redirect** para redigiremos el control de la aplicación al método de inicio para que de nuevo vuelva a listar todos los elementos disponibles.

Ya que vamos a usar los flash para mostrar los mensajes vamos a modificar la plantilla **layout.twig.html** para que tenga en cuenta estos mensajes.

{% highlight html linenos %}
<!DOCTYPE html>
<html>
 <head>
  <title>Software</title>
  <link href="estilos.css" rel="stylesheet" type="text/css" />
  <base href="http://localhost/software/" />
 </head>
 <body>
  <h1>Software</h1>
  <div id="menu">
    <ul>
      <li>
        <a href="{% raw %}{{ app.url_generator.generate('inicio') }}{% endraw %}">
            Listar
        </a>
      </li>
      <li>
        <a href="{% raw %}{{ app.url_generator.generate('insertar') }}{% endraw %}">
            Insertar
        </a>
      </li>
    </ul>
  </div>

  {% raw %}{% if app.session.hasFlash('error') or app.session.hasFlash('ok') %}{% endraw %}
    <div class="center_text">
    {% raw %}{% if app.session.hasFlash('error') %}{% endraw %}
      <span class="red">{% raw %}{{ app.session.getFlash('error') }}{% endraw %}</span>
    {% raw %}{% elseif app.session.hasFlash('ok') %}{% endraw %}
      <span class="green">{% raw %}{{ app.session.getFlash('ok') }}{% endraw %}</span>
    {% raw %}{% endif %}{% endraw %}
    </div>
  {% raw %}{% endif %}{% endraw %}

  <div id="contenido">
    {% raw %}{% block content %}{% endraw %}
    {% raw %}{% endblock %}{% endraw %}
  </div>
 </body>
</html>
{% endhighlight %}

El código añadido es bastante fácil de entender, primero mediante un **if** comprobamos si existe el flash *error* u *ok* en caso afirmativo mostramos el div y según sea el flash que existe se muestra de un color o de otro. El resto de código es el mismo que teníamos antes.

Una vez visto como podemos eliminar datos de nuestra base de datos, pasemos a la opción de insertar nuevos elementos. Para ello vamos a rellenar el método para insertar de esta sencilla forma:

{% highlight php linenos startinline=true %}
$app->get('/insertar', function() use ($app) {
    return $app['twig']->render('insertar.twig.html', array());
})->bind('insertar');
{% endhighlight %}

Este método simplemente se encargará de decir que se renderice la plantilla **insertar.twig.html** la cual crearemos a continuación dentro de la carpeta *views* de la siguiente forma:

{% highlight html linenos %}
{% raw %}{% extends "layout.twig.html" %}{% endraw %}

{% raw %}{% block content %}{% endraw %}
<form action="{% raw %}{{ app.url_generator.generate(''insertar_item'') }}{% endraw %}" 
    method="post">
  <label for="nombre">Nombre:</label>
  <br />
  <input type="text" name="nombre" id="nombre" 
      value="{% raw %}{% if nombre is defined %}{{ nombre }}{% endif %}{% endraw %}" />
  <br /><br />
  <label for="descripcion">Descripción:</label>
  <br />
  <textarea name="descripcion" id="descripcion" rows="10" cols="50">
      {% raw %}{% if descripcion is defined %}{{ descripcion }}{% endif %}{% endraw %}
  </textarea>
  <br /><br />
  <input type="submit" name="submit" value="Añadir" />
</form>
{% raw %}{% endblock %}{% endraw %}
{% endhighlight %}

Como vemos, el **action** del formulario apunta a una ruta que todavía no hemos creado en nuestro fichero **index.php**, será este controlador el encargado de insertar el nuevo elemento en la base de datos. También tenemos que fijarnos que tanto en el atributo value del input como dentro del textarea comprobamos si existen las variables *nombre* y *descripcion* para en caso de que existan mostrarlas en los campos correspondientes. Esto lo hacemos por si ocurre algún error, volver a esta página y mostrar los datos que el usuario había introducido anteriormente y porque esta misma plantilla la reutilizaremos a la hora de editar los datos.

{% highlight php linenos startinline=true %}
$app->post('/insertar', function() use($app) {

    $rows = $app['db']->insert('software', array(
        'nombre' => $app['request']->get('nombre'),
        'descripcion' => $app['request']->get('descripcion')));
    if( $rows <= 0 )
    {
        $app['session']->setFlash('error', 
            'Se ha producido un error al insertar el elemento');

        return $app['twig']->render('insertar.twig.html',array(
                'nombre' => $app['request']->get('nombre'),
                'descripcion' => $app['request']->get('descripcion')));
    }
    else
    {
        $app['session']->setFlash('ok', 'Elemento insertado correctamente');

        return $app->redirect($app['url_generator']->generate('inicio'));
    }
})->bind('insertar_item');
{% endhighlight %}

Lo primero que llama la atención es que en esta ocasión utilizamos el método **post** en vez de **get** en la llamada. Como el formulario lo vamos a enviar por post, para que esta función reciba la petición tenemos que indicarlo utilizando este método. Otra cosa que también puede llamar la atención es la ruta con la que se invoca a este método */insertar* es la misma ruta que la que nos muestra el formulario, pero como uno se llama por get y este último por post no existe ningún problema. Seguidamente utilizando el método **insert** insertamos en la tabla indicada los elementos que pasamos en el array. Como se ve, la forma de obtener los campos de un formulario es mediante la invocación al método **$app['request']->get('nombre_campo');**. A continuación y como hicimos a la hora de eliminar un elemento comprobamos si se ha inserta correctamente o no y guardamos un flash con el mensaje. Por último si todo ha sido correcto redirigimos a inicio para que vuelva a aparecer la lista con todos los elementos de la base de datos, pero si ha ocurrido algún error volvemos a mostrar la página de insertar un nuevo elemento pero pasándole en un array los datos que anteriormente el usuario había introducido para mostrárselos.


Por último nos falta el método para editar. Como hemos dicho que vamos a usar la misma plantilla que usamos para insertar datos, lo primero que hacemos es modificar un poco esta plantilla modificando la etiqueta de apertura del formulario según estemos editando o insertando.

{% highlight html linenos %}
{% raw %}{% if editar is defined and editar == true %}{% endraw %}
    <form action="{% raw %}{{ app.url_generator.generate('editar_item') }}{% endraw %}" 
        method="post">
    <input type="hidden" name="id" id="id" value="{% raw %}{{ id }}{% endraw %}" />
{% raw %}{% else %}{% endraw %}
    <form action="{% raw %}{{ app.url_generator.generate('insertar_item') }}{% endraw %}" 
        method="post">
{% raw %}{% endif %}{% endraw %}
{% endhighlight %}

Lo único que hacemos es comprobar si existe una variable llamada editar y ponemos un action del formulario distinto al de insertar además de añadirle un campo hidden para almacenar el identificador del elemento que vamos a modificar. A continuación veremos los dos métodos para modificar, al igual que insertar tenemos un método que únicamente se encarga de renderizar el formulario y otro para almacenar los datos en la base de datos.

{% highlight php linenos startinline=true %}
$app->get('/editar/{id}', function($id) use ($app) {

    $sql = 'SELECT id, nombre, descripcion FROM software WHERE id = ?';
    $soft = $app['db']->fetchAssoc($sql, array($id));

    return $app['twig']->render('insertar.twig.html', array(
        'editar' => true,
        'id' => $soft['id'],
        'nombre' => $soft['nombre'],
        'descripcion' => $soft['descripcion']));
})->bind('editar');

$app->post('/editar', function() use ($app) {

    $rows = $app['db']->update('software', array(
        'nombre' => $app['request']->get('nombre'),
        'descripcion' => $app['request']->get('descripcion')),
        array(
            'id' => $app['request']->get('id')
     ));

    if( $rows <= 0 )
    {
        $app['session']->setFlash('error', 
            'Se ha producido un error al actualizar el elementos');
        return $app['twig']->render('insertar.twig.html', array(
            'editar' => true,
            'id' => $app['request']->get('id'),
            'nombre' => $app['request']->get('nombre'),
            'descripcion' => $app['request']->get('descripcion')));
    }
    else
    {
        $app['session']->setFlash('ok', 'Se ha actualizado correctamente');
        return $app->redirect($app['url_generator']->generate('inicio'));
    }
})->bind('editar_item');
{% endhighlight %}

El código es muy similar al que hemos visto a la hora de insertar un nuevo elemento con la salvedad que ahora utilizamos el método **update** para actualizar el elemento en la base de datos.


Con esto hemos terminado de completar el ejemplo de usar Silex, Twig y Doctrine. Como siempre si queréis descargar el proyecto podéis hacerlo desde el siguiente [enlace](/uploads/posts/samples/silex-doctrine-twig-II.rar).

Para acceder a la primera parte del tutorial podéis hacerlo desde aquí: [Silex, Doctrine y Twig I](/2012/01/14/silex-doctrine-twig-i.html)