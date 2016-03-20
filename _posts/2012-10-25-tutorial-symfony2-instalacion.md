---
layout: post
comments: false
title: ! 'Tutorial Symfony 2: 1.- Instalación'
---

**Actualizado a 19 de Octubre de 2013**
Symfony 2 es uno de los frameworks más usados para trabajar con PHP. Además de facilitarnos muchas cosas a los desarrolladores ya que contiene numerosos bundles (paquetes) que podemos usar tanto con todo el conjunto del framework como por separado, nos ofrece una gran seguridad en sus componentes para poder evitar ataques a nuestras aplicaciones.

Con el propósito de mostrar como se puede crear un sitio web con Symfony voy a crear una pequeña aplicación web e iré explicando paso a paso como voy haciéndola con el fin de mostrar los principios básicos de este framework. La aplicación consistirá en un pequeño blog en el que se podrán insertar noticias y publicar comentarios sobre las noticias.

<!--more-->

Comenzaremos instalando en nuestro sistema [Composer](http://getcomposer.org). Composer es una herramienta para gestionar las dependencias de librerias externas en un proyecto PHP. Si nuestro sistema operativo es MAC o Linux simplemente podemos teclear en un terminal el siguiente comando para instalarlo:

``` none
> curl -s https://getcomposer.org/installer | php
```

Si por el contrario nuestro SO es Windows no tendremos *curl* instalado así que podemos utilizar el siguiente comando en un terminal:

``` none
> php -r "eval('?>'.file_get_contents('https://getcomposer.org/installer'));"
```

Si ninguna de estas opciones nos convence, también se puede descargar el fichero .phar de composer manualmente desde la página de [descarga de composer](http://getcomposer.org/download/) y guardarlo en la carpeta donde vayamos a crear el proyecto.

El siguiente paso que vamos a dar es instalar Symfony. La versión que vamos a instalar es la 2.3 y al igual que con composer, tenemos varias formas de instalarlo. La forma más sencilla es utilizando el mismo composer. Para ello vamos desde un terminal a la carpeta donde crearemos el proyecto, en mi caso la he llamado *blog*, y tecleamos el siguiente comando:

``` none
> composer create-project symfony/framework-standard-edition . 2.3.5
```

Si en vez de realizar la instalación de composer de forma global en tu sistema, te descargaste en fichero .phar todos los comandos de composer tendrán que empezar con *php composer.phar* en vez de únicamente *composer*. Es decir, si utilizar el fichero .phar en vez del comando anterior, tendrás que ejecutar el siguiente:

``` none
> php composer.phar create-project symfony/framework-standard-edition . 2.3.5
```

El comando le indica a composer que vamos a crear un nuevo proyecto *create-project* de symfony *symfony/framework-standard-edition*, lo crearemos en la ruta indicada a continuación *"."* (la ruta actual) y queremos instalar la versión 2.3.5. Después de esto, comenzará la descarga de todos los ficheros del framework necesarios y cuando finalice nos realizará una serie de preguntas para configurar el acceso a la base de datos y el acceso al servidor de correo en caso de que tengamos. Podemos rellenar los datos correctamente o dejar los que vienen por defecto y más tarde cambiarlos.

Otra forma de instalar Symfony es descargandolo desde su página oficial. Para ello vamos a la sección de [descargas](http://symfony.com/download) y elegimos que versión queremos descargar. Además de las distintas versiones de Symfony para descargar, cada versión la podemos encontrar con paquetes distintos .tgz o .zip y con vendors o sin ellos. El tipo de paqute .tgz o .zip no tienen diferencia, simplemente es para seleccionar el que más te gusto. En cambio, la versión sin vendors indica que no contiene las librerías extras necesarios para que symfony funcione y las tendremos descargar posteriormente. Por otro lado, la versión con vendors contiene todas las librerías en el fichero que descargaremos y una vez extraido podemos comenzar a trabajar.

Se eliga la opción que se eliga de estas dos, una vez descargado el paquete, hay que descomprimirlo y copiar todos los ficheros a nuestro directorio de trabajo, la carpeta *blog* en mi caso. Si hemos seleccionado para descargar la versión sin vendors antes de continuar tendremos que ejecutar el siguiente comando para instalarlos:

``` none
> composer install
```

Una vez instalado, tenemos que comprobar si nuestro sistema cumple con los requisitos necesarios para que Symfony funcione correctamente. Para realizar esta operación Symfony tiene un comando que ejecutaremos escribiendo en un terminal:

``` none
> php app/check.php
```

Este script se encargará de realizar un testeo en nuestro sistema para comprobar si todo es correcto. En el resultado que presenta, tenemos que diferenciar dos partes. Al inicio mostrarán los *Mandatory requirements* y más abajo los *Optional recommendations*. Como es de suponer los *Mandatory requirements* tienen que estar todos en OK para que Symfony pueda funcionar, en caso de que alguno no este correcto se nos mostrará un mensaje indicando cual es el problema y entonces tendremos que proceder a solucionarlo antes de continuar. Por su parte los *Optional recommendations* no son necesarios para que Symfony funcione, pero si los cumplimos todos, nuestro sistema será óptimo para poder proporcionar los mejores resultados.

Una vez tenemos Symfony preparado, continuamos con la configuracion del servidor web. Para ello vamos a la carpeta *conf* de apache y editamos el fichero *httpd.conf*. Buscamos la línea que pone *Include ".../.../httpd-vhosts.conf"* donde los simbolos ... son la ruta donde está instalado apache  y nos aseguramos que no está comentada (no tiene el símbolo # al principio). A continuación vamos a la carpeta *extra* que está en el mismo directorio donde el fichero que acabamos de modificar y editamos el fichero *httpd-vhosts.conf* añadiendo al final lo siguiente:

``` none
<VirtualHost *:80>
    DocumentRoot "/Applications/XAMPP/htdocs/blog/web"
    ServerName blog
    ServerAlias blog
    <Directory "/Applications/XAMPP/htdocs/blog/web"
        AllowOverride All
        Allow from All
    </Directory>
</VirtualHost>
```

Hay que tener en cuenta que las rutas que aparecen las tenemos que adaptar a las que cada uno utilice. Por ejemplo, en caso de usar Windows un ejemplo de ruta sería: C:\\xampp\\htdocs\\blog\\web

Ahora tenemos que localizar el fichero host que en sistemas {% raw %}*{% endraw %}nix suele estar en la ruta */etc* y en sistemas Windows en *C:\\WINDOWS\\system32\\drivers\\etc*. Lo abrimos y añadimos al final la siguiente línea:

``` none
127.0.0.1  blog
```

Esto lo que hará es indicarle a nuestro sistema que cuando insertemos la ruta *http://blog* en un navegador lo redirijirá a nuestro propio equipo y como en apache tendremos configurado el directorio virtual al que responde esa url se ejecutará nuestra aplicación.

Ya tenemos completamente configurada nuestra aplicación para que pueda arrancar, es el momento de iniciar apache o de pararlo y volverlo a iniciar si ya lo tenias arrancado. Una vez esté listo introducimos en un navegador la url **http://blog/app_dev.php** y se nos mostrará una pantalla como la siguiente que nos informa que todo está correcto.

![Instalación de Symfony con éxito](/uploads/posts/images/symfony-installed.jpg){:width="750px"}

Para finalizar con esta entrada, vamos a configurar la base de datos. Para ello en la pagina que se nos ha mostrado en el navegador pulsamos en la opción del centro donde pone **Configure**. Se mostrará una nueva página como la siguiente:

![Pantalla configuración Symfony](/uploads/posts/images/symfony-configuration.jpg){:width="750px"}

En la opción *Driver* seleccionaremos el driver de la base de datos a la que nos vamos a conectar, en mi caso seleccionare *MySQL (PDO)*, *Host* es el servidor en el que se encuentra la base de datos, en mi caso lo dejaré por defecto como *localhost*. El campo *Name* es el nombre que va a tener la base de datos, yo le he puesto como nombre *blog*. Los campos *User* y *Password* son para indicar el usuario y la contraseña para conectarnos a la base de datos. Una vez configurados estos campos pulsaremos el botón *Next Step* que nos llevará a una nueva pantalla donde configuraremos un token para evitar ataques [CSRF](http://es.wikipedia.org/wiki/CSRF) podemos pulsar unas cuantas veces el botón *Generate* para que se genere un token completamente aleatorio y finalmente pulsaremos en *Next Step*. La última pantalla que se nos mostrará será un resumen de todas las acciones que se han llevado a cabo. Si por algún motivo ha ocurrido algún error, en esta pantalla se nos indicará cual ha sido y de que forma podemos solucionarlo. Si todo ha ido correctamente ya tendremos configurada nuestra base de datos para poder trabajar con ella. Todos estos parámetros que hemos configurado de forma visual con ayuda de un asistente, también podemos configurarlos a mano editando el fichero *parameters.yml* que se encuentra en la ruta app/config/ de nuestro directorio de trabajo.

Hasta aquí a llegado la primera entrada de este tutorial de Symfony. En la próxima entrada ya comenzaremos a tocar algo de código PHP y a programar algo, que al fin y al cabo es lo que nos gusta a todos.

Tutorial de Symfony 2

* Instalación
* [Creación del bundle y del modelo de datos](/2012/11/08/tutorial-symfony2-creacion-bundle-y-modelo-datos.html)
* [Creación del frontend](/2013/01/18/tutorial-symfony2-creacion-del-frontend.html)
* [Trabajando con el controlador](/2013/10/27/tutorial-symfony2-trabajando-con-el-controlador.html)
* [Completando el controlador](/2014/01/05/tutorial-symfony2-completando-controlador.html)
