---
layout: post
comments: false
title: ! 'Tutorial Symfony 2: 2 - Creación del bundle y del modelo de datos'
---

**Actualizado a 19 de Octubre de 2013**
Este artículo es la segunda parte del tutorial de Symfony 2 que estoy realizando y continua donde se quedo la primera parte. Si aun no lo has visto, dale un vistazo para aprender a [Instalar Symfony 2](/2012/10/25/tutorial-symfony2-instalacion.html). Esta parte se va a centrar en crear un bundle en la aplicación y a definir el modelo de datos.

Para comenzar hay que explicar que es un bundle. Una forma fácil de definirlo es, decir que un bundle es una carpeta que contiene todo el código de una funcionalidad de la aplicación. Separar la funcionalidad de una aplicación en bundles permite que más tarde esos bundles se puedan reutilizar con otras aplicaciones sin ningún problema. La aplicación de ejemplo únicamente contendrá un bundle ya que es muy pequeña, pero por ejemplo podíamos separar la gestión de los usuarios en un bundle y toda la gestión de las entradas en el blog en otro bundle distinto.

Una vez explicado que es un bundle, toca crear uno para la aplicación. Para ello abrimos un terminal y vamos al directorio de trabajo donde instalamos Symfony. Una vez en el directorio *blog* tecleamos lo siguiente:

    > php app/console generate:bundle

Este comando inicializará un asistente para crear un nuevo bundle. La primera pregunta que hace el asistente es para que le indiquemos el namespace del bundle. El namespace normalmente suele ser el nombre de la compañía que desarrolla el bundle, seguido opcionalmente de una categoría bajo la que queremos agruparlo y finalmente el nombre del bundle terminado con la palabra bundle. Yo le voy a poner como namespace lo siguiente **jhernandz/BlogBundle**. En este caso no he indicado ninguna categoría, solamente el nombre del desarrollador y el del bundle.

<!--more-->

La segunda pregunta que realiza el asistente es para indicarle el nombre por el cual se va a referenciar al bundle dentro de la aplicación. Como sugerencia el asistente pone el namespace que le hemos indicado antes sin la barra de separación, en mi caso **jhernandzBlogBundle**. Yo lo voy a dejar de esta forma así que sin introducir nada pulso enter para continuar.

La  tercera pregunta es para indicar la ruta donde se va a crear el bundle. El bundle lo podemos crear en cualquier ruta dentro de nuestro directorio de trabajo, pero las buenas prácticas de Symfony aconsejan ubicarlo dentro de la carpeta *src* como ofrece el asistente. En este caso tampoco introduciré texto y pulsare directamente enter para dejar la opción por defecto.

En la cuarta pregunta tenemos que indicar en que formato queremos los archivos de configuración. Podemos elegir entre varias opciones, xml, yml, php y anotaciones. Yo indicaré el formato yml y pulsaré enter.

A continuación el asistente pregunta por si tiene que generar la estructura del directorio completamente. Si la contestación es si, se generarán todos los posibles directorios que puede contener nuestro bundle. En mi caso he indicado que no, pero eres libre de seleccionar la opción de que cree todos los directorios y ver que se crean muchas más carpetas dentro del bundle.

Después de estas preguntas, el asistente indica que si se confirma la generación del bundle con los datos que se han introducido. Al indicar que si, se crearan todos los ficheros necesarios. Pero el asistente no termina aquí, aun hay que contestar dos preguntas más.

La siguiente pregunta nos dice si actualiza automáticamente el kernel de la aplicación. El kernel es donde se registran todos los bundles que se van a usar en la aplicación para que Symfony los cargue a la hora de ejecutarla. El fichero que contiene el kernel se encuentra en la ruta *app/AppKernel.php*, se puede modificar manualmente y añadir el nuevo bundle, pero resulta más sencillo contestar la pregunta diciendo que si y que lo registre automáticamente.

La última pregunta del asistente nos dice que si actualiza el fichero de rutas. El fichero de rutas contendrá todas las rutas de nuestra aplicación e indicará a que bundle y a que acción de este llamar para ejecutar un código u otro. El fichero de rutas se encuentra en *app/config/routing.yml* y de nuevo podemos editarlo a mano o contestar afirmativamente a la pregunta y que se actualice automáticamente.

Con estos pasos finalizados, ya esta el bundle creado completamente. Como hemos mencionado antes, ahora vamos a crear el modelo de datos de la aplicación. Nuestro blog va a ser muy sencillo así que nuestro modelo solamente tendrá tres entidades una para los usuarios, otra para los post y la última para los comentarios.

Para comenzar a crear el modelo de datos vamos a la siguiente ruta de nuestro bundle *src/jhernandz/BlogBundle/* y creamos una nueva carpeta a la que llamaremos *Entity*. Dentro de esta carpeta crearemos todas las entidades que necesitaremos para este bundle y comenzaremos con la entidad de usuario. Así que crearemos un nuevo fichero al que llamaremos **User.php** y contendrá lo siguiente:

{% highlight php linenos startinline=true %}
<?php

namespace jhernandz\\BlogBundle\\Entity;

use Doctrine\\ORM\\Mapping as ORM;

/**
 * @ORM\\Entity
 */
class User
{
    /**
    * @ORM\\Id
    * @ORM\\Column(type="integer")
    * @ORM\\GeneratedValue
    */
    protected $id;

    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $name;
    
    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $lastName;
    
    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $email;
    
    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $password;
    
    /**
    * @ORM\\OneToMany(targetEntity="jhernandz\\BlogBundle\\Entity\\Post", 
    *    mappedBy="author")
    */
    protected $posts;
    
    
    public function __toString() 
    { 
        return $this->name . '' '' . $this->lastName; 
    }
}
{% endhighlight %}

Como se puede ver, tanto encima de la declaración de la clase como en la declaración de cada atributo existen unos comentarios. A estos comentarios se le llaman anotaciones y sirven para identificar las propiedades y la entidad con la finalidad de que Doctrine procese los datos adecuadamente para relacionarse con la base de datos.

Antes de declarar la clase, con la anotación *@ORM\\Entity* estamos indicando que esta clase será una entidad. A continuación encima del atributo *id* ponemos las anotaciones que indican que es la clave primaria de la entidad *@ORM\\Id*, el tipo que es, en este caso un entero *@ORM\\Column(type="integer")* y si el valor es autogenerado *@ORM\\GeneratedValue*. Como se puede ver a lo largo de la declaración de la entidad el tipo de la columna puede variar para ajustarse al tipo de datos que se necesita en cada ocasión. Para ver más detalles sobre las anotaciones se le puede dar un vistazo a la [documentación de Doctrine](http://docs.doctrine-project.org/projects/doctrine-orm/en/latest/reference/basic-mapping.html#doctrine-mapping-types).

Una de las anotaciones que llama más la atención es la que está sobre la variable *posts*, esta variable nos interesa que contenga un array con todos los post que ha publicado el usuario, por lo tanto será una relación de uno a muchos. Para definir esta relación utilizamos la anotacion *@ORM\\OneToMany(targetEntity="jhernandz\\BlogBundle\\Entity\\Post", mappedBy="author")* en la que indicamos que se relacionara con la entidad que posteriormente crearemos y llamaremos *Post* y se encontrará en el mismo bundle. Con el atributo *mappedBy* le indicamos que está relación estará mapeada en la entidad Post por el atributo *author*.

Al final de la clase he declarado un método llamado *__toString*. Este es método es uno de los [Magic Methods](http://www.php.net/manual/en/language.oop5.magic.php) de PHP que permitirá que cada vez que se imprima por pantalla este objeto, el resultado será lo que se indica en este método, en nuestro caso el nombre y el apellido.

Antes de continuar hay que aclarar que para que las anotaciones funcionen correctamente, hemos tenido que importar previamente el namespace *Doctrine\\ORM\\Mapping* y lo hemos renombrado como *ORM*, por ello toda declaración de las anotaciones va precedida de estas siglas.

Pasamos ahora a definir la entidad Post, creamos un nuevo fichero en la misma ruta donde se encuentra el fichero *User.php* y lo llamamos *Post.php*. En él pondremos el siguiente contenido:

{% highlight php linenos startinline=true %}
<?php

namespace jhernandz\\BlogBundle\\Entity;

use Doctrine\\ORM\\Mapping as ORM;

/**
 * @ORM\\Entity
 */
class Post
{
    /**
    * @ORM\\Id
    * @ORM\\Column(type="integer")
    * @ORM\\GeneratedValue
    */
    protected $id;
    
    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $title;
    
    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $slug;
    
    /**
    * @ORM\\Column(type="datetime", nullable=true)
    */
    protected $publishDate;
    
    /**
    * @ORM\\ManyToOne(targetEntity="jhernandz\\BlogBundle\\Entity\\User", 
    *   inversedBy="posts")
    */
    protected $author;
    
    /**
    * @ORM\\Column(type="text")
    */
    protected $content;
    
    /**
    * @ORM\\OneToMany(targetEntity="jhernandz\\BlogBundle\\Entity\\Comment", 
    *   mappedBy="post")
    */
    protected $comments;

}
{% endhighlight %}

En este caso podemos ver como hemos añadido algunos atributos nuevos en las anotaciones como el *nullable* del campo publishDate para indicar que es un campo que puede ser nulo. Como hemos dicho antes en esta entidad vamos a mapear la relación entre usuario y post. La forma de definir este mapeado la vemos con la anotación *@ORM\\ManyToOne(targetEntity="jhernandz\\BlogBundle\\Entity\\User")* que vemos encima del atributo *author* en la que indicamos que este atributo se tiene que relacionar con la entidad usuario. Además esta entidad también define una relación de uno a muchos con la entidad *Comment* que crearemos a continuación al igual que hicimos con la entidad *User* y *Post*

La última entidad que vamos a crear como he mencionado antes, se llamará *Comment*, así que crearemos de nuevo en el mismo directorio un fichero llamado *Coment.php* y su contenido será este:

{% highlight php linenos startinline=true %}
<?php

namespace jhernandz\\BlogBundle\\Entity;

use Doctrine\\ORM\\Mapping as ORM;

/**
 * @ORM\\Entity
 */
class Comment
{
    /**
    * @ORM\\Id
    * @ORM\\Column(type="integer")
    * @ORM\\GeneratedValue
    */
    protected $id;
    
    /**
    * @ORM\\Column(type="string", length=255)
    */
    protected $name;
    
    /**
    * @ORM\\Column(type="datetime", nullable=true)
    */
    protected $date;
    
    /**
    * @ORM\\Column(type="text")
    */
    protected $content;
    
    /**
    * @ORM\\ManyToOne(targetEntity="jhernandz\\BlogBundle\\Entity\\Post", 
    *   inversedBy="comments")
    */
    protected $post;
}
{% endhighlight %}

Con las anotaciones claras y las entidades definidas, nos damos cuenta que todos los atributos los hemos declarado como *protected* por lo tanto no son accesibles. Por ello necesitamos crear los métodos *getters* y *setters* para poder acceder a ellos. En vez de tener que crearlos manualmente, Symfony nos proporciona un comando que nos ayuda a crearlos automaticamente, para ello vamos a un terminal y tecleamos lo siguiente:

    > php app/console generate:doctrine:entities jhernandz\\BlogBundle

Este comando indica que se generen todas las entidades del bundle que le pasamos como segundo parámetro. Si ahora volvemos a ver de nuevo los fichero *User.php*, *Post.php* o *Comment.php* que hemos creado antes, veremos como se han añadido automáticamente todos los getters y setters necesarios.

Una vez tenemos las entities completas, crearemos nuestra base de datos, para ello desde un terminal escribimos lo siguiente:

    > php app/console doctrine:database:create

Este comando se encargará de leyendo los datos que introducimos previamente al configurar la aplicación ([tutorial de instalación](/2012/10/25/tutorial-symfony2-instalacion.html)) crear la base de datos.

A continuación y con la base de datos correctamente creada, es el turno de generar las tablas necesarias. Para este fín, Symfony pone a nuestra disposición el siguiente comando:

    > php app/console doctrine:schema:create

Este comando se encargará de leer las entidades que hemos creado anteriormente y definir todas las tablas con los atributos y las relaciones que indicamos al crear las entidades.

Al finalizar podemos acceder con PHPMyAdmin o nuestro gestor de base de datos favorito y comprobar como se ha creado correctamente la base de datos y contiene tres tablas en ella.

Aquí termina esta entrada donde hemos visto como crear un bundle y hemos definido el modelo de la aplicación. En la próxima entrada veremos como crear el frontend de la aplicación.

Tutorial de Symfony 2

* [Instalación](/2012/10/25/tutorial-symfony2-instalacion.html)
* Creación del bundle y del modelo de datos
* [Creación del frontend](/2013/01/18/tutorial-symfony2-creacion-del-frontend.html)
* [Trabajando con el controlador](/2013/10/27/tutorial-symfony2-trabajando-con-el-controlador.html)
* [Completando el controlador](/2014/01/05/tutorial-symfony2-completando-controlador.html)