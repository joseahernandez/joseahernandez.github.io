---
layout: post
comments: true
title: Entorno PHP, Nginx y MySql con Docker
---

En la última entrada comenté como empezar a [adentrarse en el mundo de Docker](http://josehernandez.xyz/2016/06/06/Docker.html), creando contenedores, parándolos y personalizándolos para nuestras necesidades. Como se pudo ver, trabajar con Docker es bastante sencillo. Por ello ahora vamos a ver como podemos crear un entorno de trabajo para proyectos PHP usando Docker.

Docker recomienda que cada contenedor contenga un proceso, en este caso utilizaré tres contenedores uno por cada una de las herramientas que se va a utilizar: PHP, Nginx y MySql. Pero antes de empezar hay que preparar en el sistema local los directorios que utilizaremos para que todo funcione correctamente.

## Configuración inicial

Lo primero será crear una estructura de directorios donde se pondrá tanto el código fuente, como los ficheros de configuración que se usarán. La ruta base que usaré será */Users/Jose/development* y a partir de ella se crearán los siguiente directorios:

* **code/myapp**: Dentro del directorio *code* estarán las aplicaciones, cada una en un subdirectorio. Para este ejemplo se creará el subdirectorio llamado *myapp*
* **config/nginx**: Configuración de Nginx
* **config/php**: Configuración de PHP
* **logs**: Directorio de logs
* **mysql/data**: Directorio donde se almacenarán los datos de MySql
* **docker**: Directorio donde pondremos la configuración de las imágenes de docker

El último paso para terminar la configuración es añadir una entrada en el fichero *hosts*. En los sistemas Linux y OsX lo podemos encontrar en la ruta */etc/hosts* y en sistemas Windows en
*c:\Windows\System32\drivers\etc\hosts*. Hay que añadir al final la siguiente línea:

```none
127.0.0.1 myapp.dev
```

<!--more-->

Al guardar el fichero con el nuevo cambio se está indicando al sistema que cada vez que se solicite la url *myapp.dev* se resuelva al host local.

Con la configuración inicial completada queda ahora crear los diferentes contenedores.

## Contenedor con PHP-FPM

Para obtener un contenedor con PHP instalado vamos a acceder a [Hub Docker](https://hub.docker.com) donde podemos encontrar multitud de contenedores disponibles para descargar y arrancar. También puedes crearte una cuenta gratuita y subir tus propios contenedores. Una vez dentro en el buscador pondremos PHP y nos aparecerán unos cuantos resultados, miraremos el que ponga en su descripción *official* (normalmente será el primer resultado). Al pinchar en él, veremos la documentación del contenedor que nos indica las versiones disponibles, como usar el contenedor y alguna que otra información de interés. En nuestro caso vamos a utilizar la última versión disponible en este momento de PHP FPM que es la 7.09.

Para conectarnos a mysql desde php vamos a utilizar el driver *pdo_mysql*, pero la imagen oficial de Docker no tiene este driver instalado, así que tendremos que crear nuestra propia imagen a partir de la oficial y añadir el driver. Para ello, vamos a la carpeta *docker*, crearemos un directorio al que llamaremos *php* y dentro de este un fichero *Dockerfile* con el siguiente contenido:

```none
FROM php:7.0.9-fpm
RUN apt-get update && docker-php-ext-install mysqli pdo pdo_mysql
```

A continuación, iremos a un terminal y desde el directorio *docker/php* ejecutaremos el siguiente comando para crear la imagen de Docker:

```none
> docker build -t josehernandez/php-fpm:7.0.9 .
```

Una vez completado y si no hemos tenido ningún error, podemos ejecutar el siguiente comando para mostrar las imágenes de docker y entre ellas aparecerá una con el nombre que le hemos dado *josehernandez/php-fpm*.

```none
> docker images
```

Para activar el driver pdo_mysql que hemos comentado anteriormente, tenemos que hacerlo desde el fichero de configuración de php, *php.ini*. Para ello, vamos al directorio *config/php* y creamos el fichero *php.ini* con el siguiente contenido: 

```none
extension=pdo_mysql.so
```

Para este ejemplo solo necesitamos poner esta configuración, pero si necesitamos ver un fichero php.ini completo para modificar algún parámetro, podemos tomar como referencia los fichero del repositorio de php para [desarrollo](https://github.com/php/php-src/blob/master/php.ini-development) o [producción](https://github.com/php/php-src/blob/master/php.ini-production) 

Con el fichero php.ini actualizado, arranquemos ahora el contenedor con el siguiente comando:

```none
> docker run -d --name php7 -v /Users/Jose/development/config/php:/usr/local/etc/php 
    -v /Users/Jose/development/code/myapp:/var/www/html/myapp 
    josehernandez/php-fpm:7.0.9
```

Los parámetros que hemos utilizado en el comando significan lo siguiente:

* **-d**: El contenedor se va a ejecutar en segundo plano
* **\-\-name php7**: El contenedor se va a llamar php7
* **-v /Users/Jose/development/config/php:/usr/local/etc/php**: Mapeamos en la ruta de nuestro sistema local /Users/Jose/development/config/php el directorio del contenedor /usr/local/etc/php. En este directorio es donde está el fichero *php.ini* para que el contendor obtenga su configuración a partir de él.
* **-v /Users/Jose/development/code/myapp:/var/www/html/myapp**: Mapeamos el código fuente de nuestra aplicación que se encuentra en /Users/Jose/development/code/myapp al directorio del contenedor /var/www/html/myapp
* **josehernandez/php-fpm:7.0.9**: La imagen que se va a arrancar es la que acabamos de crear

Para comprobar que el contenedor está funcionando correctamente, ejecutaremos el siguiente comando:

```none
> docker ps
```

Tendremos que ver que el contenedor de php está arrancado y en marcha. Con el contenedor de PHP listo pasamos ahora a configurar el contenedor para Nginx.

## Contenedor con Nginx

Para el contenedor de Nginx también vamos a ir a [Hub Docker](https://hub.docker.com) y buscaremos la imagen oficial de Nginx. En este caso la última versión estable disponible es la 1.10.1. Pero antes hay que configurar un virtual host para que apunte al directorio de la aplicación. Para ello, dentro de la carpeta para la configuración de Nginx (*/Users/Jose/config/nginx* en mi caso) se creará un fichero llamado *myapp.conf* con el siguiente contenido:


    server {
        index index.php index.html;
        server_name myapp.dev;

        error_log  /var/log/nginx/myapp_error.log;
        access_log /var/log/nginx/myapp_access.log;

        root /var/www/html/myapp;

        location ~ \.php$ {
            try_files $uri =404;
            fastcgi_split_path_info ^(.+\.php)(/.+)$;

            fastcgi_pass php7:9000;

            fastcgi_index index.php;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
        }
    }

Este es un fichero típico de configuración de Nginx. Algunos de los campos más importantes son el *server_name* donde se indica que las acciones descritas a continuación se ejecutarán cuando se solicite ese servidor. Las rutas de los fichero de acceso y de error (/var/log/nginx/myapp_error.log y /var/log/nginx/myapp_access.log) estas rutas pertenecen a la ruta de ficheros de dentro del contenedor Docker, no de nuestro sistemas host. También se indica donde está la ruta del código fuente de la aplicación (/var/www/html/myapp) de nuevo con la ruta dentro del sistema de ficheros del contenedor y finalmente una de las características más importantes, en la línea 14 se indica donde se está ejecutando el proceso php-fpm. Sabemos que este proceso se está ejecutando en el contenedor que hemos arrancado antes, pero una característica que tienen los contenedores Docker es que su ip puede variar cada vez que arranque el contenedor. Por ello, en vez de poner la ip, se indica el nombre que le hemos dado al contenedor al arrancar, si recordamos era *php7*. Con esto e indicando a la hora de arrancar este nuevo contenedor que cree un enlace con el contenedor de php automáticamente se resolverá ese nombre a la ip con la que haya arrancado el contenedor php.

Con estos pasos completamos vamos ahora a arrancar este nuevo contenedor, para ello ejecutamos el siguiente comando:

```none
> docker run -d --name nginx -v /Users/Jose/develpment/config/nginx:/etc/nginx/conf.d 
    -v /Users/Jose/development/code/myapp:/var/www/html/myapp 
    -v /Users/Jose/development/logs:/var/log/nginx -p 8080:80 
    --link php7 nginx:1.10.1
```

El significado de los parámetros son los siguientes:

* **-d**: El contenedor se va a ejecutar en segundo plano
* **\-\-name nginx**: El contenedor se va a llamar nginx
* **-v /Users/Jose/development/config/nginx:/etc/nginx/conf.d**: Mapeamos en nuestra ruta local /Users/Jose/development/config/nginx el directorio del contenedor /etc/nginx/conf.d donde se encuentra la configuración de Nginx
* **-v /Users/Jose/development/code/myapp:/var/www/html/myapp**: Mapeamos también el directorio con el código fuente de la aplicación que se encuentra en /Users/Jose/development/code/myapp al directorio del contenedor /var/www/html/myapp
* **-v /Users/Jose/development/logs:/var/log/nginx**: Mapeamos el directorio local /Users/Jose/development/logs con el directorio del contenedor /var/log/nginx donde se guardarán los logs de Nginx
* **-p 8080:80**: Hacemos que se redirija las conexiones que van al puerto 8080 de nuestro host al puerto 80 del contenedor
* **\-\-link php7**: Linkamos el contenedor con el contenedor antes creado llamado php7
* **nginx:1.10.1**: La imagen que se arranca es la versión 1.10.1 de nginx

Es el momento de probar que tanto Nginx como PHP están funcionando correctamente. Para ello en la ruta donde está el código de la aplicación (/Users/Jose/development/code/myapp) crearemos un fichero al que llamaremos *index.php* y contendrá el siguiente código:

```php
<?php
    echo 'Hello World';
?>
```

Si ahora abrimos un navegador y vamos a la url *http://myapp.dev:8080* deberemos ver una página con el mensaje *Hello World*.

## Contenedor MySql

Para el último contenedor, de nuevo seguiremos los mismos pasos que hasta ahora, ir a Hub Docker y buscar en este caso la imagen oficial de MySql. En este momento la última versión es la 5.7.14 que es la que usaremos. Es interesante darle un vistazo a la documentación ya que se utilizarán algunas de las opciones que se indican a la hora de crear el contenedor. Para crear el contenedor se ejecutará el siguiente comando:

```none
> docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=password 
    -e MYSQL_DATABASE=docker_sample 
    -v /Users/Jose/development/mysql/data:/var/lib/mysql mysql:5.7.14
```

Los parámetros que indicamos en el comando son:

* **-d**: El contenedor se ejecuta en segundo plano
* **\-\-name**: El contenedor se llamará mysql
* **-e MYSQL_ROOT_PASSWORD=password**: La contraseña de usuario root será password
* **-e MYSQL_DATABASE=docker_sample**: Se creará una base de datos llamada docker_sample al inicializar el contenedor por primera vez
* **-v /Users/Jose/development/mysql/data:/var/lib/mysql**: Mapeamos el directorio local /Users/Jose/development/mysql/data con el directorio del contenedor /var/lib/mysql que es donde mysql guardará todos los datos sobre las base de datos.
* **mysql:5.7.14**: La imagen que se arranca es la versión 5.7.14 de mysql

En el ejemplo se utiliza el usuario root, pero es muy recomendado por temas de seguridad no utilizar este usuario. En la documentación del contenedor se puede ver como crear un usuario para que acceda a la base de datos creada. 

Para comprobar que MySql está arrancado correctamente y que se ha creado la base de datos que hemos indicado en el comando, podemos arrancar otro contenedor con la línea de comando de MySql del a siguiente forma:

```none
> docker run -it --link mysql --rm mysql sh -c 'exec mysql 
    -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" 
    -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
```

Una vez arrancado el contenedor tendremos la línea de comandos de MySql disponible desde la cual podremos ejecutar comando, crear bases de datos, tablas … Para ver si la base de datos que hemos indicado *docker_sample* se ha creado, ejecutaremos la siguiente sentencia:

```sql
show databases;
```

Vamos ahora a ejecutar varios comandos para crear una tabla y unos cuantos datos en ella:

```sql
use docker_sample;

create table users (
    id int not null auto_increment primary key,
    name varchar(100) not null,
    last_name varchar(250) not null
);

insert into users (name, last_name) VALUES
    ("Jose", "Hernández"),
    ("Emilio", "García"),
    ("Marta", "Gómez"),
    ("Luis", "López"),
    ("Laura", "Moreno");
```

Si en vez de utilizar el cliente en línea de comandos de mysql te sientes más cómodo usando otro tipo de cliente como [Workbench](https://www.mysql.com/products/workbench/) puedes utilizar el siguiente comando para arrancar el contenedor de mysql:

```none
> docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password 
    -e MYSQL_DATABASE=docker_sample 
    -v /Users/Jose/development/mysql/data:/var/lib/mysql mysql:5.7.14
```

En este comando le hemos añadido el parámetros *-p 3306:3306* que redirige la conexión del puerto 3306 de nuestro equipo host al puerto 3306 del contenedor. De esta forma conectándonos a localhost con cualquier cliente de mysql podremos acceder a la base de datos.


## Poniendo en funcionamiento los tres contenedores

Una vez visto como crear los contenedores, es el momento de ponerlos todos en marcha y comprobar que una aplicación funciona correctamente en ellos. Lo primero que vamos a hacer es crear un script PHP que acceda a nuestra base de datos, recupere información de los usuario y se la muestre al cliente en el navegador.

Volvemos a editar el fichero *index.php* que se encuentra en la ruta de la aplicación (/Users/Jose/development/code/myapp), lo borramos por completo y escribimos el siguiente código:

```php
<?php
    $pdo = new \PDO('mysql:host=localhost;dbname=docker_sample', 'root', 'password'); 
    $res = $pdo->query('select name, last_name from users');
    foreach ($res as $user) {
        echo '<p>' . $user[0] . ' - ' . $user[1];
    }
?>
```

A continuación, nos aseguramos que todos los contenedores están parados. Para ello podemos ejecutar el comando:

```none
> docker ps
```

El resultado mostrará los contenedores que están en marcha. Si tenemos alguno arrancado, lo pararemos con el comando stop e indicando el nombre del contenedor. En mi caso para parar los tres contenedores ejecutaré el siguiente comando: 

```none
> docker stop mysql php7 nginx
```

En este momento tenemos que hacer un cambio en la forma de arrancar los contenedores, ya que ahora queremos que nuestro contenedor php se conecte al de mysql. Para ello borraremos los contenedores que hemos creado de php y nginx y los volveremos a arrancar para linkarlos con mysql. Borrar un contenedor se realiza con el comando rm y el nombre del contenedor:

```none
> docker rm php7 nginx
```
    
A continuación arrancaremos los contenedores en el siguiente orden: mysql, php y nginx. Comencemos con el de mysql:

```none
> docker start mysql
```

El siguiente es el de php, para el que usaremos el mismo comando que usamos antes, pero le añadiremos el link con el contendor de mysql (*\-\-link mysql*): 

```none
> docker run -d --name php7 -v /Users/Jose/development/config/php:/usr/local/etc/php 
    -v /Users/Jose/development/code/myapp:/var/www/html/myapp --link mysql 
    josehernandez/php-fpm:7.0.9
```

Finalmente arrancaremos el contenedor de nginx. Este comando no cambiará, pero como hemos vuelto a crear el contenedor de php, tenemos que volver a crear el de nginx para que se actualize el link.

```none
> docker run -d --name nginx 
    -v /Users/Jose/development/config/nginx:/etc/nginx/conf.d 
    -v /Users/Jose/development/code/myapp:/var/www/html/myapp 
    -v /Users/Jose/development/logs:/var/log/nginx -p 8080:80 
    --link php7 nginx:1.10.1
```

Comprobamos que los tres contenedores están arrancados

```none
> docker ps
```

Y accederemos con el navegador a la url *http://myapp.dev:8080* en la cual podremos ver los nombres que hemos introducido anteriormente en la base de datos.

Desde este momento para parar los contenedores podremos volver a usar el comando stop como vimos anteriormente y si queremos arrancarlos usaremos el comando start:

```none
> docker start mysql php7 nginx
```

## Docker compose para arrancar todos los contenedores a la vez

Como hemos visto a lo largo del post los comandos para crear y arrancar los contenedores son bastante largos y es bastante sencillo cometer un error. Además siempre tenemos que tener en cuenta el orden en el que los arrancamos para que los enlaces entre ellos se realicen correctamente. Para mejorar este proceso vamos a utilizar [Docker compose](https://docs.docker.com/compose/overview/). 

Docker compose es una herramienta que permite definir y arrancar multiples contenedores a la vez. Para ello en un fichero se definen los contenedores y a través de él se arrancan y paran los contenedores.

Este fichero lo llamaremos *docker_compose.yml* y lo crearemos dentro de la carpeta *docker* de nuestro directorio de trabajo. Su contenido será el siguiente:

```
version: '2'
services:
  php7:
    container_name: php7
    build: ./php
    volumes:
      - /Users/Jose/development/config/php:/usr/local/etc/php
      - /Users/Jose/development/code/myapp:/var/www/html/myapp
    depends_on:
      - mysql

  nginx:
    container_name: nginx
    image: nginx:1.10.1
    ports:
      - 8080:80
    volumes:
      - /Users/Jose/development/config/nginx:/etc/nginx/conf.d
      - /Users/Jose/development/code/myapp:/var/www/html/myapp
      - /Users/Jose/development/logs:/var/log/nginx
    depends_on:
      - php7

  mysql:
    container_name: mysql
    image: mysql:5.7.14
    volumes:
      - /Users/Jose/development/mysql/data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=docker_sample
```

Es un fichero yaml en el que se definen los contenedores que se van a crear. En los ficheros yaml, como este, es muy importante mantener la identación de cada uno de los elementos ya que de lo contrario no funcionaría correctamente.

El fichero comienza con el atributo **version** que indica la versión de fichero docker compose que se va a usar, en este caso la 2. A continuación con el atributo **service** indicamos los contenedores que se van a crear y su configuración. Como vemos en el fichero hemos creado tres servicios *php7*, *nginx* y *mysql* cada uno corresponde a un contenedor de los que hemos creado anteriormente. Los atributos que definen cada uno de los contenedores son los siguientes: 

* **container_name**: Nombre que va a tener el contenedor.
* **build**: Se indica la ruta de un fichero *Dockerfile* para construir el contenedor.
* **image**: Se indica el nombre de la imagen de la cual que se a crear el contenedor. Como vemos si indicamos el atributo *image* no se indica el atributo *build* ya que en el Dockerfile está definida la imagen base del contenedor.
* **ports**: Array con los puertos que se van a mapear entre el host local y el contendor.
* **volumes**: Array indicando la ruta de ficheros que se va a mapear entre el host local y el contenedor.
* **environment**: Array con las variables de entorno que se van ha definir en el contenedor.
* **depends_on**: Array con el identificador del servicio que queremos linkar al contenedor actual. Es importante saber que se refiere al identificador que ponemos en el servicio y no al valor indicado en el atributo *container_name*.

Una vez creado este fichero, vamos con un terminal a la ruta donde está y arrancamos todos los contenedores con el siguiente comando:  

```none
> docker-compose up
```

Este comando creará y arrancará los tres contenedores que hemos definido. Si queremos que los contenedores se ejecuten en segundo plano como demonios añadiremos al comando el atributo *\-d*.

Con los contenedores arrancados ya podemos volver a acceder a la url de nuestra aplicación y ver el resultado. Además del comando *up* para manejar docker compose tenemos los siguientes comandos:

Para arrancar las contenedores una vez que están creados ejecutaremos:

```none
> docker-compose start
```

Para parar contenedores:

```none
> docker-compose stop
```

Para parar contenedores y eliminarlos:

```none
> docker-compose down
```

## Conclusiones

Como se ha visto a lo largo de esta entrada no ha costado mucho crear un entorno de trabajo para aplicaciones PHP con Docker. Además, lo único que hemos tenido que instalar en nuestro sistema ha sido Docker, ya que el resto de herramientas PHP, MySql y Nginx solo están instaladas en cada uno de los contenedores, de forma que nuestro sistema no se ve afectado. Otra de las ventajas es que podemos cambiar las versiones de todas las herramientas e incluso incluir nuevas herramientas simplemente arrancando un nuevo contenedor y linkandolo al resto.

Creo que Docker aporta muchas ventajas tanto en el desarrollo como en la puesta en producción de nuestras aplicaciones y habría que darle una oportunidad para ver si se ajusta satisfactoriamente a las necesidades de cada uno.
