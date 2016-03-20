---
layout: post
comments: false
title: Interfaces Gráficas en C++ con Qt
---

Qt es un framework multiplataforma que nos permite, entre otras cosas, desarrollar interfaces gráficas para nuestras aplicaciones. También es usado para desarrollar otro tipo de aplicaciones, pero en esta entrada quiero centrarme sobre todo en las características para crear interfaces gráficas cuando trabajamos con C++.

En algunos pequeños proyectos que he realizado he trabajado con la biblioteca [wxWidgets](http://www.wxwidgets.org), pero ahora quiero ver cuáles son las características que puede ofrecer Qt y de paso mostrar como poder crear una aplicación con este framework. Lo primero que haremos será descargarlo, para ello visitaremos la sección de [descargas](http://qt.nokia.com/downloads) de su página oficial y seleccionaremos descargar el entorno de desarrollo completo que, además del framework nos descargará el IDE de Qt.

Cuando finalice su descarga y posterior instalación, abrimos el Qt Creator y creamos un nuevo proyecto de tipo Qt Gui Application. Se abrirá el asistente y en él indicaremos el nombre del proyecto y la localización donde lo guardaremos. Seguidamente nos preguntará si queremos cambiar el nombre de las clases y ficheros iniciales que nos creará por defecto. Por último nos preguntará si queremos poner el proyecto bajo algún control de versión. Una vez realizados estos pasos nos aparecerá una ventana como la siguiente.

![Pantalla inicial](/uploads/posts/images/pantalla_inicial.png)

<!--more-->

En esta pantalla podemos ver el diseñador de la interfaz gráfica. En la parte central se muestra el formulario que estamos editando, en la parte izquierda encontramos distintos controles que podemos usar y en la parte derecha tenemos los objetos que actualmente están en el formulario y las propiedades del objeto seleccionado actualmente.

Si pulsamos el botón **Run**, ![Run](/uploads/posts/images/boton_run.png) que se encuentra situado en la parte inferior izquierda, la aplicación se compilará y se ejecutará mostrándonos el siguiente resultado.

![Primera ejecución](/uploads/posts/images/primera_ejecucion.png)

Como se puede observar de momento tenemos poca cosa, así que vamos a añadirle algo más a nuestra aplicación. El ejemplo que vamos a realizar es muy sencillo y no tiene ninguna complicación, el objetivo es ver cómo podemos comenzar el desarrollo de una aplicación con la ayuda de este framework.

Para comenzar cerramos la ventana con el programa en ejecución y hacemos clic en el formulario de edición, posteriormente vamos a las propiedades y buscamos **windowTitle**. Cambiamos su valor por *Hello World!*, ahora el título de nuestra aplicación será ese. A continuación vamos a los controles y arrastramos un **Push Button** hasta el formulario de edición. Hacemos doble clic izquierdo encima de él cuando esté en el formulario de edición y escribimos *Mensaje*. Con esto le hemos cambiado su propiedad **text**, que es el texto que se mostrará encima del botón. También podemos cambiar la propiedad **objectName** que es el nombre con el que se identificará nuestro botón en la aplicación, yo le he llamado *buttonMensaje*. Ahora pulsamos clic derecho encima del botón y seleccionamos del menú contextual la opción <strong>Go to slot</strong>. Se nos abrirá una nueva ventana donde nos aparecerán todos los eventos que puede lanzar un botón, seleccionaremos la opción **clicked()** y pulsamos Ok. Seguidamente se nos mostrará el código del formulario con el método **on_buttonMensaje_clicked()** ya creado. Es dentro de este método donde declararemos que es lo que queremos hacer cuando se pulse el botón.

![Ventana con código](/uploads/posts/images/ventana_codigo.png)

La funcionalidad del ejemplo será mostrar un mensaje cuando se pulse el botón, para ello lo primero que hago es incluir la cabecera para poder mostrar una ventana con un mensaje.

``` none
#include <qmessagebox.h>
```

Posteriormente y dentro del método que se ejecuta cuando se pulsa el botón pondré el siguiente código.

``` none
QMessageBox::information(this, "Mensaje información", "Bienvenido a mi primera 
    aplicación Qt");
```

Si ahora ejecutamos la aplicación y pulsamos el botón, el resultado que obtendremos será similar a esta imagen.

![Resultado final](/uploads/posts/images/resultado_final.png)

Ahora puedes ir investigando el resto de controles e ir viendo las propiedades y los eventos que tienen. Como has visto no es muy complicado crear una interfaz gráfica con Qt así que si estás interesado en la programación con Qt quizás sea un buen momento para mirar la [documentación oficial](http://doc.qt.nokia.com/4.6/) con el fin de adquirir más conocimientos. Como siempre si quieres obtener todo el código del ejemplo puedes descargarlo desde [aquí](/uploads/posts/samples/Proyecto-Qt-HelloWorld.rar)
