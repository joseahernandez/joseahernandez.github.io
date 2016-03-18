---
layout: post
comments: false
title: ! 'Tutorial Symfony 2: 4 - Trabajando con el controlador'
---

En la última entrada del tutorial de Symfony 2 creamos la página principal de nuestro blog, mostrando información que introducíamos directamente en el controlador. Ahora vamos a modificar ese controlador para que busque las entradas del blog en una base de datos.

Pero antes de comenzar a poner código en nuestro controlador y consultar la base de datos, sería interesante tener algunos datos en ella. A estos datos de prueba, se les llama **fixtures** y gracias a un bundle de Doctrine podemos crear clases que se encarguen de rellenar, con los datos que indiquemos, nuestra base de datos de forma rápida. Además también nos  permite eliminar todos los datos y volverlos a cargarlos.

Vamos a instalar el bundle para poder crear nuestras fixtures, así que abrimos el fichero *composer.json* que encontraremos en la raíz de nuestro proyecto y después de la clave **require** añadimos lo siguiente:

<!--more-->

    ...
    "require": {
        ...
    },
    "require-dev": {
        "doctrine/doctrine-fixtures-bundle": "dev-master"
    },
    ...

Lo que hemos indicado a composer es que cuando estemos en modo de desarrollo (development) queremos que al llamar a composer install o composer update, nos instale además de las dependencias indicadas en la clave *require*, las indicadas en *require-dev*.

Lo siguiente que tenemos que hacer es instalar la dependencia que acabamos de indicar, para ello tecleamos el siguiente comando en un terminal:

    > composer update

Comenzará la descarga del nuevo bundle y cuando finalice únicamente tendremos que activarlo en nuestra aplicación. Para llevar a cabo la activación, abriremos el fichero *AppKernel.php* que se encuentra en la carpeta *app* y en la función *registerBundles*, dentro del if que comprueba si estamos en el entorno de dev o test, añadiremos el nuevo bundle descargado.

{% highlight php linenos startinline=true %}
public function registerBundles()
{
    ...
    if (in_array($this->getEnvironment(), array('dev', 'test'))) {
        ...
        $bundles[] = new Doctrine\Bundle\FixturesBundl\
            DoctrineFixturesBundle();
    }
    ...
}
{% endhighlight %}

Para comprobar si el nuevo bundle se ha instalado correctamente escribiremos en un terminal:

    > app/console

Si en la lista de comandos que aparecen se encuentra *doctrine:fixtures:load* el bundle estará instalado y activado correctamente.

Ahora pasaremos a crear nuestros ficheros de fixtures. Estos ficheros por convención suelen situarse en el directorio del bundle al que pertenece la entidad, dentro de *DataFixtures/ORM*, así que para nuestro ejemplo crearemos estas dos carpetas para obtener la ruta *src/jhernandz/BlogBundle/DataFixtures/ORM* y dentro de la carpeta *ORM* el fichero *Users.php* con el siguiente código:

{% highlight php linenos startinline=true %}
namespace jhernandz\BlogBundle\DataFixtures\ORM;

use Doctrine\Common\DataFixtures\AbstractFixture;
use Doctrine\Common\DataFixtures\OrderedFixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;

use jhernandz\BlogBundle\Entity\User;

class Users extends AbstractFixture implements OrderedFixtureInterface
{
    public function load(ObjectManager $manager)
    {
        $user = new User();
        
        $user->setName('Jose');
        $user->setLastName('Hernández');
        $user->setEmail('josehernandez@email.es');
        $user->setPassword('123456');
        
        $manager->persist($user);
        $manager->flush();
    }

    public function getOrder()
    {
        return 1;
    }
}
{% endhighlight %}

Esta clase se va a encargar de crearnos un usuario y almacenarlo en la base de datos. Como podemos observar la clase implementa dos métodos, *getOrder* simplemente indica el orden en el que se van a ejecutar todos los ficheros de fixtures que tengamos. En este caso este será el primer fichero que se ejecutará y cargará sus datos en la base de datos. El otro método *load* se encarga de crear un usuario y almacenarlo en la base de datos. Para ello, se crea un objeto de tipo **User** y se le asignan los atributos que queramos. A continuación, con ayuda del objeto **ObjectManager** que recibe como parámetro el método load, se llama al  método **persist** que se encarga de almacenar en memoria el objeto que acabamos de crear. Finalmente se llama al método **flush** que es el encargado de almacenar todos los objetos que se hayan almacenado en memoria mediante las llamadas a **persist** en la base de datos.

En el método **load** podríamos haber creado tantos usuarios como quisiéramos, aunque yo he optado por crear solamente uno. Para probar que funciona correctamente nuestro fichero de fixtures, abrimos un terminal y ponemos los siguiente:

    > app/console doctrine:fixtures:load

Este comando eliminará todo el contenido de nuestra base de datos y ejecutará todos los ficheros de fixtures que tengamos, insertando los datos en ella. En nuestro caso insertará únicamente el usuario que acabamos de crear. Si nos conectamos a la base de datos con PHPMyAdmin o nuestro gestor de base de datos preferido, podemos ver como en la tabla *user* tenemos el usuario almacenado. Aquí podemos ver un grave problema de seguridad puesto que la contraseña se ha almacenado en texto plano. De momento vamos a dejarlo así y en una próxima entrada explicaré como solucionar este problema.

Vamos a seguir creando nuevos fixtures para las dos tablas que nos quedan, así que ahora creamos el fichero *Posts.php* con el siguiente código:

{% highlight php linenos startinline=true %}
namespace jhernandz\BlogBundle\DataFixtures\ORM;

use Doctrine\Common\DataFixtures\AbstractFixture;
use Doctrine\Common\DataFixtures\OrderedFixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;

use jhernandz\BlogBundle\Entity\User;
use jhernandz\BlogBundle\Entity\Post;

class Posts extends AbstractFixture implements OrderedFixtureInterface
{
    public function load(ObjectManager $manager)
    {
        $users = $manager->getRepository("jhernandzBlogBundle:User")
            ->findAll();

        foreach ($users as $user) {
            for ($i = 1; $i < 5; $i++) {
                $post = new Post();
                    $post->setTitle("Noticia " . $i);
                    $post->setSlug("noticia-" . $i);
                    $post->setPublishDate(new \DateTime());
                    $post->setAuthor($user);

                    $content = >>>EOF
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor dolor 
non purus placerat vulputate. Vestibulum imperdiet elementum pellentesque. 
Curabitur sit amet sem magna. Quisque venenatis tortor sed velit vulputate 
eleifend sed et quam. Maecenas laoreet dictum tellus, eu dictum turpis tempor 
et. Suspendisse potenti. Nunc turpis mi, tristique ac rhoncus quis, eleifend 
quis tortor.</p>
EOF;
                    $post->setContent($content);
                    
                    $manager->persist($post);
            }
        }

        $manager->flush();
    }

    public function getOrder()
    {
        return 2;
    }
}
{% endhighlight %}

En esta ocasión hemos utilizado el objeto **ObjectManager** para recuperar todos los usuario que hay en la base de datos. Para recuperarlos, lo primero que le hemos hecho es obtener mediante  el **ObjectManager** el repositorio *jhernandzBlogBundle:User*, que como nos podemos imaginar, es el repositorio de la clase **User**, a continuación llamamos al método **findAll()** del repositorio que se encargará de devolvernos un array de objetos **User** con todos los usuario que hay en la base de datos. El siguiente paso, es recorrer todos los usuarios y crear 4 posts para cada uno de ellos. En el ejemplo solo se ha creado un usuario, por lo tanto únicamente se crearán 4 post.

Finalmente el último fichero de fixtures que vamos a crear es *Comments.php* y que contendrá el siguiente código:

{% highlight php linenos startinline=true %}
namespace jhernandz\BlogBundle\DataFixtures\ORM;

use Doctrine\Common\DataFixtures\AbstractFixture;
use Doctrine\Common\DataFixtures\OrderedFixtureInterface;
use Doctrine\Common\Persistence\ObjectManager;

use jhernandz\BlogBundle\Entity\Post;
use jhernandz\BlogBundle\Entity\Comment;

class Comments extends AbstractFixture implements OrderedFixtureInterface
{
    public function load(ObjectManager $manager)
    {
        $posts = $manager->getRepository("jhernandzBlogBundle:Post")
            ->findAll();

        foreach ($posts as $post) {
            $commentsNumbers = rand(0, 5);

            for ($i = 1; $i <= $commentsNumbers; $i++) {
                $comment = new Comment();
                $comment->setName("Coment Usu " . $i);
                $comment->setDate(new \DateTime());
                $comment->setPost($post);

                $content = >>>EOF
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed nisi metus, 
pellentesque a tempus eu, rutrum eu odio. Maecenas varius aliquet nulla, ut 
fringilla massa venenatis a. Pellentesque nulla nibh, cursus vel adipiscing 
a, venenatis ac nisl. Nulla in ante ligula, vel molestie enim. Pellentesque 
pulvinar nulla ut ante dapibus nec lacinia orci malesuada. Curabitur aliquet 
elementum tempus. Pellentesque habitant morbi tristique senectus et netus et 
malesuada fames ac turpis egestas. Vivamus sed quam et turpis euismod 
lobortis. Maecenas scelerisque consectetur odio ut imperdiet. Vestibulum ante 
ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae</p>
EOF;

                $comment->setContent($content);

                $manager->persist($comment);
            }
        }

        $manager->flush();
    }

    public function getOrder()
    {
        return 3;
    }
}
{% endhighlight %}

El contenido es bastante similar al fichero de post, pero esta vez creando un número aleatorio de comentarios para cada uno de los posts que tenemos.

Una vez que tenemos todos los fichero creados y después de haber llamado al comando *app/console doctrine:fixtures:load* en la base de datos tendremos todos esos datos cargados, así que ahora vamos a ir al controlador para decirle que los post que muestre los lea de la base de datos. Abrimos el fichero *src/jhernandz/BlogBundle/Controller/DefaultController.php* borramos el contenido del método **indexAction** y escribimos lo siguiente:

{% highlight php linenos startinline=true %}
namespace jhernandz\BlogBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;

use jhernandz\BlogBundle\Entity\Post;

class DefaultController extends Controller
{
    public function indexAction()
    {
        $em = $this->getDoctrine()->getManager();
        $posts = $em->getRepository("jhernandzBlogBundle:Post")->findAll();

        return $this->render(
            'jhernandzBlogBundle:Default:index.html.twig', 
            array('posts' => $posts)
        );
    }
}
{% endhighlight %}

Como se puede apreciar el contenido del controlador lo hemos dejado en 3 líneas que son las encargadas de realizar todo el trabajo. Si vamos ahora a la url *http://blog/app_dev.php* podemos observar como se muestra la página al igual que antes, pero esta vez con los valores obtenidos desde la base de datos. Todo parece correcto, pero si nos fijamos en la barra de depuración de Symfony, situada en la parte inferior, podemos ver que se ejecutan 6 consultas a la base de datos. Si miramos detalladamente las consultas que se realizan podemos ver que hay una consulta para obtener los posts, otra consulta para obtener el nombre del usuario y 4 consultas más para obtener los comentarios de cada post. Si los post tuvieran distintos autores tendríamos más consultas para obtener todos los autores y si tuviéramos más post tendríamos muchas más consultas para obtener todos los comentarios. Como podemos imaginar con varios post podemos tener numerosas consultas a la base de datos cosa que no es buena para el rendimiento de nuestro sitio web. Así que tenemos que reducir ese número de consultas. Para ello vamos a crear una consulta personalizada que obtenga toda esta información con una sola consulta.

Esta consulta personalizada la crearemos en una nueva clase que comúnmente se conoce como repositorio. En estas clases repositorios, se crean métodos que se encargan de consultar la base de datos y devolver los datos solicitados. En nuestro caso, como vamos a hacer una consulta sobre los post crearemos una clase llamada *PostRepository* así que creamos en la ruta *src/jhernandz/BlogBundle/Entity* el fichero *PostRepository.php*. Este fichero contendrá el siguiente código:

{% highlight php linenos startinline=true %}
namespace jhernandz\BlogBundle\Entity;

use Doctrine\ORM\EntityRepository;

class PostRepository extends EntityRepository
{
    public function findAllPostsWithComments()
    {
        $em = $this->getEntityManager();

        $dql = 'SELECT ' .
                    'p as post, count(c.id) as comments, a.name ' .
                'FROM ' .
                    'jhernandzBlogBundle:Post p ' .
                    'LEFT JOIN p.comments c ' .
                    'JOIN p.author a ' .
                'GROUP BY p.id';
        $query = $em->createQuery($dql);

        $res = $query->getResult();

        return $res;
    }
}
{% endhighlight %}

Como podemos ver hemos creado un método llamado *findAllPostsWithComments* que se encargará de recuperar todos los post, el nombre del autor y el número de comentarios. Si nos fijamos bien en la consulta, observaremos que no se trata de una consulta SQL normal. Doctrine utiliza un lenguaje llamado DQL para realizar las consultas, podemos encontrar más información en su [página oficial](https://doctrine-orm.readthedocs.org/en/latest/reference/dql-doctrine-query-language.html?highlight=dql). Es bastante sencillo comprender este lenguaje ya que es muy parecido al SQL normal, pero más orientado a objetos.

Para comprender la dql nos fijamos en la componente *FROM* en la cual se le indica que se quieren buscar objetos de la entity Post haciendo un left join con la entity Comments que se relaciona con Post mediante la propiedad *comments* de este último. A su vez, también queremos hacer un JOIN entre Post y Author y esta relación se lleva a cabo mediante la propiedad *id* de la entity Post. El siguiente paso es mirar la componente *SELECT* en la cual indicamos que queremos recuperar la entity Post completamente, queremos hacer un count de los id de la entity Comment y además, queremos el atributo name de la entity Author. Finalmente, decimos que queremos agrupar los elementos por la componente id de la entity Post. Al igual que en una consulta sql, también podíamos haber agregado una componente *WHERE* para definir más la consulta, pero en este caso no era necesario.

El siguiente paso que tenemos que dar antes de poder llamar a este método, es indicarle a la entity que cuenta con una clase repositorio donde tendrá métodos para poder utilizar. Esto se realiza añadiendo un atributo a las anotaciones de las entities, para ello nos vamos a editar el fichero *Post* y lo actualizamos de la siguiente forma:

{% highlight php linenos startinline=true %}
namespace jhernandz\BlogBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="PostRepository")
 */
class Post
{
    ...
{% endhighlight %}

Lo único que hemos hecho ha sido añadirle a la anotación *Entity* el atributo *repositoryClass* y a continuación le hemos indicado el nombre de la clase que actual como repositorio.

Ahora es el turno de irnos al *DefaultController.php* y actualizar en el método *indexAction* la llamada al método del repositorio *findAll* por la nueva:

{% highlight php linenos startinline=true %}
public function indexAction()
{
    $em = $this->getDoctrine()->getManager();
    $items = $em->getRepository("jhernandzBlogBundle:Post")
        ->findAllPostsWithComments();

    return $this->render(
        'jhernandzBlogBundle:Default:index.html.twig', 
        array('items' => $items)
    );
}
{% endhighlight %}

Lo último que nos queda por hacer es actualizar la plantilla de la vista, ya que el método *findAllPostsWithComments* no devuelve un array de objetos Post como el método *findAll*, si no que devuelve un array de arrays cuya primera componente es un objeto Post, su segunda componente es un entero con el número de comentarios y su tercera componente es un string con el nombre del autor. Así que vamos al fichero *src/jhernandz/Resources/view/Default/index.html.twig* y lo dejamos de la siguiente manera:

{% highlight html linenos %}
{% raw %}{% extends '::base.html.twig' %}{% endraw %}

{% raw %}{% block stylesheets %}{% endraw %}
    <link href="{% raw %}{{ asset('bundles/jhernandzblog/css/post.css') }}{% endraw %}"
        rel="stylesheet" type="text/css" />
{% raw %}{% endblock %}{% endraw %}

{% raw %}{% block body %}{% endraw %}
    {% raw %}{% for item in items %}{% endraw %}
        <article class="post">
            <header><h1><a href="#">{% raw %}{{ item.post.title }}{% endraw %}</a></h1></header>
            {% raw %}{{ item.post.content | raw }}{% endraw %}
            <footer class="footer">
                {% raw %}{{ item.post.publishDate | date("d/m/Y") }}
                    por {{ item.name }}{% endraw %}
                <span class="pull-right">{% raw %}{{ item.comments }}{% endraw %} Comentarios</span>
            </footer>
        </article>
    {% raw %}{% endfor %}{% endraw %}
{% raw %}{% endblock %}{% endraw %}
{% endhighlight %}

Si volvemos a probar la página y miramos la barra de depuración, vemos que ahora únicamente se realiza una consulta, con lo que hemos conseguido mejorar el rendimiento de la aplicación.

Hasta aquí esta entrada, en la próxima veremos como implementar la página de detalle de una entrada y como permitir añadir comentarios


Tutorial de Symfony 2

* [Instalación](/2012/10/25/tutorial-symfony2-instalacion.html)
* [Creación del bundle y del modelo de datos](/2012/11/08/tutorial-symfony2-creacion-bundle-y-modelo-datos.html)
* [Creación del frontend](/2013/01/18/tutorial-symfony2-creacion-del-frontend.html)
* Trabajando con el controlador
* [Completando el controlador](/2014/01/05/tutorial-symfony2-completando-controlador.html)
