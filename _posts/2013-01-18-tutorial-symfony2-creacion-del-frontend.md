---
layout: post
comments: false
title: ! 'Tutorial Symfony 2: 3 - Creación del frontend'
---

**Actualizado a 19 de Octubre de 2013**
Continuamos con la serie de tutoriales sobre Symfony 2 y en esta ocasión vamos a crear el frontend de nuestro blog y a definir algunas rutas. Para realizar estas tareas, Symfony nos proporciona dos herramientas muy útiles dentro de su framework. A la hora de crear el frontend vamos a usar el sistema de plantillas [Twig](http://twig.sensiolabs.org). Mientras que para las rutas usaremos el sistema de [enrutamiento](http://symfony.com/doc/current/book/routing.html).

Comenzaremos definiendo la ruta de la página principal. Si recuerdas la entrada sobre la [creación del bundle y el modelo de datos](/2012/11/08/tutorial-symfony2-creacion-bundle-y-modelo-datos.html) ya indicamos donde podemos encontrar el fichero de rutas. Así que vamos a la carpeta *app/config* y abrimos el fichero **routing.yml**. En mi caso el contenido de este fichero es el siguiente:

```yaml
jhernandz_blog:
    resource: "@jhernandzBlogBundle/Resources/config/routing.yml"
    prefix:   /
```

<!--more-->

La primera línea que vemos *jhernandz_blog* es el nombre que va a tener la ruta. En la segunda línea e identada (en los ficheros yml es importante la identación y se debe realizar mediante espacios, no mediante tabulador) tenemos la clave **resource** que indica que se tienen que importar las rutas desde el fichero que se encuentra en la ruta *Resources/config/routing.yml* dentro del bundle *jhernandzBlogBundle*. Finalmente la tercera línea tenemos la clave **prefix** que indica que cadena predecerá a las rutas que se importarán. En este caso como solo se indica **/** quiere decir que las rutas no se verán precedidas por nada, pero si hubiésemos indicado */entrada*, todas las rutas que indiquemos en el fichero routing del bundle irían siempre precedidas de la palabra *entrada*.

Después de explicar cada uno de los elementos del fichero nos damos cuenta que este fichero simplemente sirve para importar las rutas de los bundles que se usen en la aplicación. Es cierto que en este fichero podríamos poner las rutas y trabajar como si el fichero routing del bundle no existiera, pero para una mejor claridad en la aplicación este fichero se deja simplemente para importar las rutas de otros bundles y las rutas de la aplicación las definiremos en el fichero routing del bundle.

Ahora abrimos el fichero *src/jhernandz/BlogBundle/Resources/config/routing.yml* y nos encontramos que este fichero contiene lo siguiente:

```yaml
jhernandz_blog_homepage:
    pattern:  /hello/{name}
    defaults: { _controller: jhernandzBlogBundle:Default:index }
```

Esta ruta es una ruta de ejemplo que se crea por defecto. Si miramos la clave **pattern** nos indica que cuando en la url aparezca la cadena */hello* seguida de algo (al poner un nombre entre las llaves {} indicamos que en esa posición de la ruta aparecerá una cadena que posteriormente enviaremos al controlador en una variable que en este caso se llamara *name*) se ejecutará por el controlador que indicaremos en la clave **defaults**, en este caso el método *index* del controlador *Default* del bundle *jhernandzBlogBundle*.

Podemos abrir el fichero *src/jhernandz/BlogBundle/Controller/DefaultController.php* y observaremos como aparece el método *indexAction* que recibe una variable llamada *name*. De momento no vamos a prestarle atención a lo que realiza este método, pero si a la nomenclatura tanto del controlador como del método. En el fichero de rutas, dijimos que se ejecutaría el método *index* del controlador *Default*, pero posteriormente hemos visto como el controlador se llama *DefaultController* y el método *indexAction*. Esta nomenclatura la tendremos que respetar siempre, el nombre de un controlador tendrá que terminar con la palabra Controller y el nombre de un método que se ejecute desde una ruta, finalizará con la palabra Action. Aunque posteriormente cuando nos refiramos al controlador o al método no le añadiremos la terminación como hemos visto en las rutas.

Una vez finalizadas estas explicaciones vamos a borrar todo el contenido del fichero *routing.yml* del bundle y vamos a añadir lo siguiente:

``` yaml
home:
    pattern: /
    defaults: { _controller: jhernandzBlogBundle:Default:index }
```

Hemos creado una ruta a la que llamamos *home* que se ejecutará cada vez que accedamos a la raíz del sitio (/) y llamará al método *index* del controlador *Default*. La finalidad de esta ruta es que cuando alguien acceda a nuestro blog se le muestren todas las entradas, una detrás de otra y ordenadas cronológicamente.

El siguiente paso que vamos a dar es crear un layout para nuestro blog. Un layout lo podemos definir como el esqueleto de nuestro sitio web, es toda la estructura que va a permanecer del mismo modo en todas nuestras páginas como pueden ser el título, el pie ... Los layouts los podemos definir a nivel de bundle, añadiéndolos bajo la ruta *Resources/views/* de cada bundle o a nivel de la aplicación en la ruta *app/Resources/views/*. Los layouts se pueden heredar, es decir, se puede definir un layout a nivel de aplicación y luego a nivel de bundle heredarlo y añadirle nuevas características. En nuestro caso, únicamente vamos a tener un layout a nivel de aplicación, así que abrimos el fichero *app/Resources/views/base.html.twig* y añadimos lo siguiente:

``` html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
      <title>{% raw %}{% block title %}JHernandz Blog{% endblock %}{% endraw %}</title>
      <link href="{{ asset('bundles/jhernandzblog/css/bootstrap.css') }}" 
          rel="stylesheet" type="text/css" />

      {% raw %}{% block stylesheets %}{% endblock %}{% endraw %}
      <link rel="icon" type="image/x-icon" href="{{ asset('favicon.ico') }}" />
  </head>
  <body>
    <header class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="brand" href="{% raw %}{{ path('home') }}{% endraw %}">JHernandz Blog</a>
        </div>
      </div>
    </header>

    <div class="container" style="margin-top:75px" >
      <div class="row">
        <div class="span12">
          {% raw %}{% block body %}{% endblock %}{% endraw %}
        </div>
      </div>
    </div>

    {% raw %}{% block javascripts %}{% endblock %}{% endraw %}
  </body>
</html>
```

Como podemos ver casi todo es código HTML que define la estructura general del blog. Pero además podemos ver algunas líneas que no contienen código HTML, este código esta escrito en Twig y gracias a él definiremos las plantillas que tendrá nuestra aplicación. Las llamadas a funciones de Twig, siempre irán entre **{% raw %}{{{% endraw %}** y **{% raw %}}}{% endraw %}**, mientras que las instrucciones irán entre **{% raw %}{%{% endraw %}** y **{% raw %}%}{% endraw %}**. En este código podemos ver 3 llamadas a funciones y 4 instrucciones.

Aunque hay varias llamadas, solamente hay una instrucción en esta plantilla, **block**. Esta instrucción lo que hace es indicar que entre su etiqueta de apertura y de cierre hay un bloque que cualquier plantilla que herede de esta puede rellenar introduciendo información. La etiqueta de apertura de **block** viene seguida del nombre que le queremos dar al bloque como por ejemplo *title*. Además podemos poner información dentro del bloque en esta plantilla (ejemplo del bloque *title*) que lo que hará es: si una nueva plantilla que hereda de esta no define este bloque dejará el valor que tiene el bloque que ha heredado y si ponemos otro valor en la nueva plantilla, no mostrará el valor actual si no el nuevo que indiquemos.

Además de la instrucción tenemos 3 funciones, aunque dos de ellas son iguales.  La primera función que aparece es **asset**, a esta función le pasamos la ruta de un recurso en nuestro carpeta web, ya sea una css, una imagen, un fichero js... y se incluirá en el código HTML como vemos que ocurre con la hoja de estilo que se ve en el ejemplo. La otra función que se muestra es **path** que pasándole el nombre de una ruta, automáticamente genera la url de esa ruta para poder navegar hasta ella.

Para el diseño del blog voy a usar el [bootstrap](http://getbootstrap.com/2.3.2/), así que lo que tenemos que acceder a su pagina web y descargarlo. A continuación, lo descomprimimos y en nuestro proyecto vamos a la ruta *src/jhernandz/BlogBundle/Resources*, en ella creamos una nueva carpeta que llamaremos *public* y dentro de public tres nuevas carpetas llamadas *css*, *img* y *js*. Volvemos a las carpetas descomprimidas del bootstrap y copiamos el fichero *bootstrap.css* en nuestra carpeta css, el fichero *bootstrap.js* de la carpeta *js* en nuestra carpeta *js* y los fichero *glyphicons-halflings.png* y *glyphicons-halflings-white.png* de la carpeta *img* en nuestra carpeta *img*.

Además del bootstrap vamos a añadir una hoja de estilo para aplicar algunos estilos propios en nuestro blog y personalizarlo un poco. Para ello creamos un fichero llamado *post.css* dentro de *src/jhernandz/BlogBundle/Resources/public/css* y ponemos lo siguiente:

``` css
.post
{
  box-shadow: 5px 5px 5px #888888; 
  margin-bottom:75px; 
  padding: 15px; 
  text-align:justify;
}

.post.footer
{
  font-size: 12px; 
  margin: 20px auto -10px;
}
```

Ahora accedemos a una terminal y tecleamos lo siguiente:

``` none
> php app/console assets:install
```

Este comando copiará los estilos que acabamos de agregar, las imágenes y los scripts del bundle en la carpeta web/bundles/jhernandzblog para que podamos acceder a ellos desde las paginas que creemos. Una pregunta que puede aparecer en este momento es el porque copiamos primero estos ficheros dentro del bundle si después vamos a copiarlos a la carpeta web. La respuesta es porque de esta forma, podemos mover el bundle a otra aplicación y todos los estilos que tenga aplicado el bundle también nos los llevaremos.

A continuación vamos a crear la plantilla principal de nuestro blog que será la que se muestre nada mas acceder a él. Para ello vamos a la ruta *src/jhernandz/BlogBundle/Resources/views/Default* y abrimos para editar el fichero *index.html.twig*, en caso de que no exista este fichero lo creamos. El código que pondremos será el siguiente:

``` html
{% raw %}{% extends '::base.html.twig' %}{% endraw %}

{% raw %}{% block stylesheets %}{% endraw %}
    <link href="{{ asset('bundles/jhernandzblog/css/post.css') }}" rel="stylesheet" 
        type="text/css" />
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block body %}{% endraw %}

    {% raw %}{% for post in posts %}{% endraw %}
        <article class="post">
            <header><h1><a href="#">{% raw %}{{ post.title }}{% endraw %}</a></h1></header>

            {% raw %}{{ post.content | raw }}{% endraw %}

            <footer class="footer">
                {% raw %}{{ post.publishDate | date("d/m/Y") }} por {{ post.author }}{% endraw %}
                <span class="pull-right"> {% raw %}{{ post.comments | length }}{% endraw %} 
                    Comentarios
                </span>
            </footer>

        </article>
    {% raw %}{% endfor %}{% endraw %}

{% raw %}{% endblock %}{% endraw %}
```

La primera línea de la plantilla utiliza la instrucción **extends** para heredar de una plantilla que indicamos al lado de la instrucción. En este caso, el nombre de la plantilla lo hemos precedido del símbolo *::* que le indicará a Twig que busque esta plantilla en la ruta *app/Resources/views*. Si hubiésemos querido que heredara de otra plantilla que estuviese alojada en algún bundle, simplemente tendríamos que haber puesto la ruta del bundle sin los *::*

A continuación, podemos distinguir claramente dos instrucciones **block** en las cuales vamos a rellenar con los datos que queremos mostrar. En la primera de ellas *stylesheets* enlazamos una nueva hoja de estilos. En la otra *body* vamos a recorrer con la instrucción **for** la variable *posts* e iremos almacenando en cada iteración un objeto del array en la variable *post*. El array *posts* lo tendremos que pasar desde el controlador como se verá posteriormente. Dentro del bucle for vamos intercalando código HTML con código Twig para mostrar la información que nos interesa. Dentro del bucle, la primera llamada a Twig que vemos es *{% raw %}{{ post.title }}{% endraw %}* esta llamada se encarga de buscar dentro del objeto que contiene la variable *post* el método *getTitle* y muestra su contenido por pantalla (En realidad la búsqueda es más completa, puedes ver más detalles en la [entrada sobre Twig](/2011/08/27/twig-plantillas-php-ii.html) que realicé hace tiempo).

La siguiente instrucción que encontramos es *{% raw %}{{ post.content \| raw }}{% endraw %}* la cual como el anterior caso buscará el método para obtener el contenido, pero además le aplicará el filtro *raw*. El filtro *raw* lo que hace es no escapar los caracteres que contiene la variable anterior. En este caso como la información de la noticia suponemos que no vendrá de un usuario seguro, no necesitamos escapar los caracteres ya que el código introducido no será maligno y dejamos la posibilidad de que las noticias se redacten con código HTML.

Si continuamos tenemos más llamadas a distintos métodos de la clase post en las que a algunos les aplicamos filtros: *date* para formatear la fecha y *length* para contar el número de objetos en un array. Twig cuenta con muchos más filtros que se pueden consultar en su [página](http://twig.sensiolabs.org/doc/filters/index.html).

En este momento ya tenemos la página de inicio de nuestro blog completa, ahora para poder ver como queda vamos a editar el controlador con unos datos de prueba para simplemente ver cual es el resultado. Para ello editamos el fichero *DefaultController.php* que se encuentra en la ruta *src/jhernandz/BlogBundle/Controller* y ponemos el siguiente código:

``` php
<?php
namespace jhernandz\BlogBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

use jhernandz\BlogBundle\Entity\Post;
use jhernandz\BlogBundle\Entity\User;

class DefaultController extends Controller
{
    public function indexAction()
    {
    $author = new User();
    $author->setName('Jose');
    $author->setLastName('Hernández');
    
    $posts = array();
    
    for ($i = 0; $i < 5; $i++) {
        $post = new Post();
        $post->setTitle('Noticia ' . $i);
        $post->setSlug('Noticia-' . $i);
        $post->setPublishDate(new \DateTime());
        $post->setAuthor($author);
        $post->setContent('Lorem ipsum dolor sit amet, consectetur ' .
            'adipiscing elit. Donec auctor dolor non purus placerat ' .
            'vulputate. Vestibulum imperdiet elementum pellentesque. ' .
            'Curabitur sit amet sem magna. Quisque venenatis tortor ' .
            'sed velit vulputate eleifend sed et quam. Maecenas ' .
            'laoreet dictum tellus, eu dictum turpis tempor et. ' .
            'Suspendisse potenti. Nunc turpis mi, tristique ' .
            'ac rhoncus quis, eleifend quis tortor'.
        );

        $posts[] = $post;
    }
    
    return $this->render(
        'jhernandzBlogBundle:Default:index.html.twig', 
        array(
            'posts' => $posts
        )
    );
  }
}
```

De momento no quiero hablar mucho sobre el controlador ya que lo veremos en la siguiente entrada. Simplemente diré que se ha creado un autor, varios posts y finalmente lo hemos pasado a la plantilla con el método **render** indicando la plantilla que se va a ejecutar y pasándole los posts en una variable llamada *posts*.

Con esto ya podemos poner en nuestro navegador la url del blog http://blog/app_dev.php y podremos ver el resultado de la página de inicio.

Tutorial de Symfony 2

* [Instalación](/2012/10/25/tutorial-symfony2-instalacion.html)
* [Creación del bundle y del modelo de datos](/2012/11/08/tutorial-symfony2-creacion-bundle-y-modelo-datos.html)
* Creación del frontend
* [Trabajando con el controlador](/2013/10/27/tutorial-symfony2-trabajando-con-el-controlador.html)
* [Completando el controlador](/2014/01/05/tutorial-symfony2-completando-controlador.html)
