---
layout: post
comments: false
title: Actualizada la forma de crear un proyecto en Silex
---


Con las últimas versiones de Silex, la forma de crear un proyecto ha variado un poco. Anteriormente se utilizaba un fichero phar que se podía descargar desde la web del framework, esa forma de crear una nueva aplicación ha quedado obsoleta y desde la propia página web de descarga de Silex nos proponen dos formas distintas de crear una nueva aplicación.

La primera de ellas consiste en descargar un archivo .zip o .tgz con todos los elementos necesarios para hacer funcionar Silex. Una vez descomprimido el archivo descargado tendremos en nuestro directorio dos carpetas una llamada *vendor* donde están todas las librerías necesarias para que Silex funcione correctamente y otra carpeta *web* donde tendremos nuestro fichero php para comenzar a programar. Existen dos fichero para descargar uno llamado *slim* y otro *fat* lo único que los diferencia es que la versión *fat* contiene más librerías para poder usar en el proyecto, mientras que con la versión *slim* las tendríamos que descargar nosotros.

<!--more-->

La segunda forma de obtener Silex es mediante Composer. Para ello tenemos que crear una carpeta en el directorio que vayamos a trabajar y dentro de ella crear un fichero llamado *composer.json* en este fichero indicaremos las librerías y la versión de ellas que necesitamos en formato json. El nuestro nos quedaría de la siguiente forma:

    {
        "require": {
            "silex/silex": "1.0.*"
        },
        "minimum-stability": "dev"
    }

Con el fichero creado, abrimos un terminal y escribimos lo siguiente para descargar composer e instalarlo en nuestro directorio de trabajo.

    > curl -s http://getcomposer.org/installer | php

En caso de no tener instalado curl podemos descargar el fichero desde la ruta http://getcomposer.org/installer y guardarlo en nuestro directorio de trabajo como installer.php, posteriormente ejecutamos en un terminal lo siguiente para instalarlo:

    > php installer.php

Una vez que tenemos composer instalado vamos a decirle que nos instale las dependencias de nuestro proyecto, en este caso Silex, para ello de nuevo en un terminal escribimos:

    > composer.phar install

Al finalizar la descarga de las dependencias creamos una carpeta llamada *web* y comenzamos a trabajar en ella.

Como vemos aunque ha cambiado la forma de crear un proyecto no es nada complicado siguiendo los pasos que he indicado anteriormente. Si estas interesado en saber más sobre Silex aquí te dejo algunas entradas que te pueden ayudar:

* [Silex, micro framework para PHP](/2011/07/13/silex-micro-framework-php.html)
* [Silex y Twig](silex-twig.html)
* [Silex, Doctrine y Twig I](silex-doctrine-twig-i.html)
* [Silex, Doctrine y Twig II](silex-doctrine-twig-ii.html)