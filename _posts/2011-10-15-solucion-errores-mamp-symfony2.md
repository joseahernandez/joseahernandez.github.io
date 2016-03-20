---
layout: post
comments: false
title: Solución errores MAMP y Symfony 2
---

Al empezar a desarrollar aplicaciones con [Symfony 2](http://symfony.com/) en OSX decidí instalar [MAMP](http://www.mamp.info/en/index.html) para tener de una forma rápida y sencilla en mi equipo apache, php y mysql. Era la primera vez que trabajaba con MAMP ya que anteriormente en otros sistemas operativos siempre he utilizado XAMPP. Pero el comienzo no iba a ser tan sencillo, nada más intentar crear la base de datos con el comando de Symfony 2

``` none
> app/console doctrine:create:database
```

Obtuve un error que no me dejaba crear la base de datos. El error era el siguiente:

``` none
Could not create database for connection named NombreBaseDatos
SQLSTATE[HY000] [2002] No such file or directory
```

<!--more-->

Después de mucho buscar, conseguí encontrar la solución para poder crear la base de datos y que no surgiera este error. Para ello tuve que crear una carpeta llamada mysql dentro de /var

``` none
> mkdir /var/mysql
```

A continuación añadí un enlace simbólico del fichero **mysql.sock** dentro de esta carpeta. Para ello usé el comando:

``` none
> sudo ln -s /Applications/MAMP/tmp/mysql/mysql.sock /var/mysql/mysql.sock
```

Con esto ya no saltaba ningún problema a la hora de crear la base de datos desde Symfony. Pero los problemas no acabaron aquí. Al mapear una clase e indicar que un campo era de tipo fecha e intentar construir el esquema de la base de datos ocurría otro error:

``` none
DateTime::__construct(): It is not safe to rely on the system's timezone settings. 
You are *required* to use the date.timezone setting or the 
date_default_timezone_set() function. 
In case you used any of those methods and you are still getting this warning, you 
most likely misspelled the timezone identifier. We selected 'Europe/Berlin' for 
'CEST/2.0/DST' instead 
```

Para solucionar este problema, simplemente hay que copiar el fichero **php.ini** del directorio MAMP a la carpeta etc dentro de private de esta forma:

``` none
> sudo cp /Applications/MAMP/bin/php/php5.3.6/conf/php.ini /private/etc
```

Con esto he solucionado los problemas que me han surgido hasta el momento al trabajar en Symfony 2 con MAMP. Si me encuentro con nuevos problemas iré publicando las soluciones que encuentre para ellos.