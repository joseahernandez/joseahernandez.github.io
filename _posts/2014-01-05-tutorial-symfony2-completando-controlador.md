---
layout: post
comments: false
title: ! 'Tutorial Symfony 2: 5 - Completando el controlador'
---

Si has seguido el tutorial anterior sobre los [controladores de Symfony 2](/2013/10/27/tutorial-symfony2-trabajando-con-el-controlador.html), ya tendrás una ligera idea de como hay que implementarlos y como se crean las diferentes *actions* en ellos. Para continuar con el tutorial, en esta entrada vamos a crear un nuevo *action* que responderá a la petición para ver el detalle de una entrada.

El primer paso que vamos a hacer es definir una ruta para ver el detalle de los posts. Para ello vamos al fichero *src/jhernandz/BlogBundle/Resources/config/routing.yml* y le añadimos una nueva ruta que llamaremos **detail**:

```yaml
home:
    pattern: /
    defaults: { _controller: jhernandzBlogBundle:Default:index }

detail:
    pattern: /post/{slug}
    defaults: { _controller: jhernandzBlogBundle:Default:detail}
```

<!--more-->

Podemos ver que el pattern de esta nueva ruta es bastante distinto del patter que teníamos en *home*. El pattern de *home* nos indica que el action asociado se ejecutará cuando se solicite una url sin ningún parámetro más. En cambio en *detail* estamos diciendo que se ejecuta el action cuando la url sea **/post/** seguido de una cosa que hemos llamado *{slug}*. Las **{ }** indican que lo que viene dentro de ellas es una variable en la que cualquier carácter que se inserte en la url quedará almacenada en ella. Si por ejemplo la url que nos llega es *http://blog/post/my-first-post* el valor de la variable **slug** será *my-first-post*. Si la url es *http://blog/post/1* el valor será *1*. Además, esto también está indicando que el action **detail** del controlador **Default** va a recibir esta variable *slug* como parámetro. De forma que la declaración de este action será así:

```php
<?php
public function detailAction($slug)
{
}
```

Una vez que conocemos estos detalles vamos a ver como usarlos. Si recordamos de la definición de la entity *Post* tenemos un atributo que llamamos **slug**. La idea es usar este atributo como identificador del post y que cuando se solicite la url de un post determinado se use una url como *http://blog/post/my-first-post* que es más elegante y los buscadores tendrán ese resultado más en cuenta que una url como *http:/blog/post/1*.

Con esto en mente, ahora tenemos que modificar la plantilla donde se muestran todas las entradas para añadirles la url del detalle. Para esto usaremos la función **path** que generará una url a la ruta que indiquemos. En nuestro caso la usaremos indicando que genere la ruta a *detail* y como parámetro le indicaremos el slug de la noticia a la que queremos que genere la ruta, como por ejemplo:

```none
{% raw %}{{{% endraw %} path('details', {% raw %}{{% endraw %} 'slug': 'my-first-post'{% raw %}}{% endraw %}) {% raw %}}}{% endraw %}
```

Como podemos ver, el segundo parámetro de la función **path** es un array de Twig, en el que como clave indicamos el nombre de la variable que pusimos cuando definimos la ruta en el fichero *routing.yml* y el valor será el que queramos que tenga la variable.

Ahora que vamos a crear la ruta para los detalles de los post, también sería buena idea crear una ruta en la etiqueta que indica el número de comentarios que tiene cada post y que apunte directamente al primer comentario de la noticia. Para esto utilizaremos también la función path para que genere la ruta y después le añadiremos el [anchor](http://en.wikipedia.org/wiki/HTML_anchor#Ancho) quedándonos de la siguiente forma:

```none
{% raw %}{{ path('details', {'slug': 'my-first-post'}) }}#comments{% endraw %}
```

Una vez que hemos entendido como funciona la generación de rutas, modificamos la plantilla *index.html.twig* y la dejamos de la siguiente manera:

```html
{% raw %}{% extends '::base.html.twig' %}{% endraw %}

{% raw %}{% block stylesheets %}{% endraw %}
    <link href="{% raw %}{{ asset('bundles/jhernandzblog/css/post.css') }}{% endraw %}" 
        rel="stylesheet" type="text/css" />
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block body %}{% endraw %}
    {% raw %}{% for item in items %}{% endraw %}
        <article class="post">
            <header>
                <h1>
                    <a href="{% raw %}{{ path('detail', {'slug' : item.post.slug}) }}{% endraw %}">
                        {% raw %}{{ item.post.title }}{% endraw %}
                    </a>
                </h1>
            </header>

            {% raw %}{{ item.post.content | raw }}{% endraw %}

            <footer class="footer">
                {% raw %}{{ item.post.publishDate | date("d/m/Y") }} por 
                {{ item.name }}{% endraw %}
                <span class="pull-right">
                    <a href="{% raw %}{{ path('detail', {'slug' : item.post.slug}) }}{% endraw %}
                        #comments">
                        {% raw %}{{ item.comments }}{% endraw %} Comentarios</span>
                    </a>
            </footer>

        </article>
    {% raw %}{% endfor %}{% endraw %}
{% raw %}{% endblock %}{% endraw %}
```

El siguiente paso que tenemos que dar es completar el controlador que se encargará de mostrar los detalles del post. Su funcionamiento es bastante sencillo, como ya hemos mencionado antes, recibirá un parámetro con el slug del post del que queremos ver los detalles, así que tendrá que buscar en la base de datos ese post y renderizarlo en una plantilla. Vamos al fichero *DefaultController.php* y completemos el action de la ruta detalle de la siguiente forma:

```php
public function detailAction($slug)
{
    $em   = $this->getDoctrine()->getManager();
    $post = $em->getRepository('jhernandzBlogBundle:Post')
        ->findOneBySlug($slug);

    if (null == $post) {
        throw $this->createNotFoundException('Invalid slug for a post');
    }

    return $this->render(
        'jhernandzBlogBundle:Default:detail.html.twig',
        array(
            'post' => $post
        )
    );
}
```

Como ya hicimos anteriormente en otra entrada, estamos obteniendo el *EntityManager* de doctrine. A continuación obtenemos el repositorio de la clase *Post* y finalmente llamamos al método **findOneBySlug**. Doctrine nos proporciona unos métodos que podemos utilizar combinandolos con las propiedades del objeto sobre el que hacemos la consulta para obtener datos. Estos métodos son los siguientes:

* findBy
* findOneBy

Como en el ejemplo, a estos métodos se le puede concatenar el nombre de un atributo de la entity sobre el que se va a realizar la búsqueda. La diferencia entre estos dos métodos es que el método **findBy** obtendrá un array con todas las ocurrencias del atributo indicado, mientras que el método **findOneBy** únicamente obtendrá una.

El siguiente paso es comprobar si se ha obtenido un Post. En caso de que no se haya obtenido ninguno, se crea una excepción con el método **createNotFoundException** para indicarlo y en caso de que si exista, se llama a la función **render** indicando está vez una nueva plantilla, *jhernandzBlogBundle:Default:detail.html.twig*, que veremos a continuación y el Post seleccionado.

Con el controlador terminado, pasamos ahora a editar la plantilla. Como hemos mencionado antes, crearemos un fichero llamado *jhernandzBlogBundle:Default:detail.html.twig* en la ruta de nuestro proyecto *src/jhernandz/BlogBundle/Resources/views/Default* y esta plantilla contendrá el siguiente código:

```html
{% raw %}{% extends '::base.html.twig' %}{% endraw %}

{% raw %}{% block stylesheets %}{% endraw %}
    <link href="{% raw %}{{ asset('bundles/jhernandzblog/css/post.css') }}{% endraw %}" 
        rel="stylesheet" type="text/css" />
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block body %}{% endraw %}
    <section>
        <header>
            <h1>{% raw %}{{ post.title }}{% endraw %}>/h1>
            <small>Publicado por {% raw %}{{ post.author }} el {{ post.publishDate | 
                date('d/m/Y') }}{% endraw %}</small>
        </header>
        <article>
            {% raw %}{{ post.content | raw }}{% endraw %}
        </article>

        <div>
            <h2><a id="comments">Coments</a></h2>
            {% raw %}{% for comment in post.comments %}{% endraw %}
                <div>
                    <p>Comentario de <strong>{% raw %}{{ comment.name }}{% endraw %}</strong> 
                        el {% raw %}{{ comment.date | date('d/m/Y') }}{% endraw %}</p>
                    <p>{% raw %}{{ comment.content }}{% endraw %}</p>
                </div>
            {% raw %}{% endfor %}{% endraw %}
        </div>
    </section>
{% raw %}{% endblock %}{% endraw %}
```

Si ahora vamos a la url de nuestra página *http://blog/app_dev.php* y pinchamos encima del título de cualquier noticia, nos redirigirá a la página de detalle, donde podremos ver toda la noticia con sus comentarios. De nuevo, si nos fijamos en la barra de depuración de Symfony, podemos ver que se ejecutan tres consultas. Si pulsamos en ella veremos que una es la que obtiene el post, otra el autor y la última los comentarios. Vamos a optimizar un poco esto para obtener a la vez el post y el autor. De esta formas nos ahorrarnos una consulta y obtendremos un mejor rendimiento. Para ello vamos de nuevo a la clase *PostRepository* que se encuentra en *src/jhernandz/BlogBundle/Entity* y añadimos el siguiente método:

```php
public function findPostWithAuthor($slug)
{
    $em = $this->getEntityManager();

    $dql = 'SELECT ' .
                'p as post, a as author ' .
            'FROM ' .
                'jhernandzBlogBundle:Post p ' .
                'INNER JOIN p.author a ' .
            'WHERE ' .
                'p.slug = :slug';

    $query = $em->createQuery($dql);
    $query->setParameter('slug', $slug);

    return $query->getOneOrNullResult();
}
```

Con el método creado, vamos al controlador para utilizar esta nueva función quedando su código de la siguiente manera:

```php
public function detailAction($slug)
{
    $em   = $this->getDoctrine()->getManager();
    $post = $em->getRepository('jhernandzBlogBundle:Post')
        ->findPostWithAuthor($slug);

    if (null == $post) {
        throw $this->createNotFoundException('Invalid slug for a post');
    }

    return $this->render(
        'jhernandzBlogBundle:Default:detail.html.twig',
        array(
            'post' => $post['post']
        )
    );
}
```

Como ya ocurrió en la entrada anterior, al utilizar un método de nuestro repositorio que obtiene dos objetos mediante una dql (Post y Author) el resultado es un array asociativo con una única componente llamada *post* que contiene al objeto Post, por lo tanto a la plantilla le pasamos esta componente del array. Si vemos de nuevo el número de consultas que se han realizado, podemos comprobar que se han reducido a solamente dos.

Para terminar esta entrada vamos a añadir unos estilos a nuestra css para visualizar algo mejor esta pantalla de detalles, así que abrimos el fichero *post.css* que se encuentra en la ruta *src/jhernandz/BlogBundle/Resources/public/css* y le añadimos las siguientes lineas:

```css
article
{
    text-align: justify;
    margin-top: 15px;
}

.comments
{
    margin-top: 55px;
}

.comment
{
    margin-bottom: 25px;
}
```

Finalmente en un terminal ejecutaremos el siguiente comando para que se actualice la css y ya podemos ver como nos ha quedado la pagina de detalle.

```none
> php app/console assets:install
```

Así finaliza la entrada de hoy. En la próxima crearemos un formulario Symfony para poder añadir comentarios y veremos cómo gestionarlo.


Tutorial de Symfony 2

* [Instalación](/2012/10/25/tutorial-symfony2-instalacion.html)
* [Creación del bundle y del modelo de datos](/2012/11/08/tutorial-symfony2-creacion-bundle-y-modelo-datos.html)
* [Creación del frontend](/2013/01/18/tutorial-symfony2-creacion-del-frontend.html)
* [Trabajando con el controlador](/2013/10/27/tutorial-symfony2-trabajando-con-el-controlador.html)
* Completando el controlador