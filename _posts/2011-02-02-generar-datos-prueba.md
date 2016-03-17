---
layout: post
comments: false
title: Generar datos de prueba
---

Hoy voy a hablaros de una herramienta muy útil que a todo desarrollado le va a venir muy bien. Uno de los trabajos más pesado a la hora de desarrollar una aplicación que trabaja con una base de datos es insertar datos de prueba en ella. [Generatedata](http://www.generatedata.com/#generator) es una aplicación web que genera datos de prueba para que los exportemos e insertemos en nuestra base de datos. Así, de una forma rápida y sencilla tenemos muchos datos listos y podemos probar nuestra aplicación.

![GenerateData](/uploads/posts/images/generatedata_logo.png)

<!--more-->

La forma de utilizarla es muy sencilla, en concreto para cada tabla para la que queramos generar datos tenemos que indicar el nombre de la columna y el tipo de dato que queremos. Entre los distintos tipos de datos tenemos: nombres, apellidos, fechas, ciudades, números... en definitiva casi cualquier tipo de campo que necesitemos. Además algunos tipos de campos tienen más opciones para refinar más los datos, como por ejemplo, podemos decir que solamente queremos nombres de mujeres o fechas que estén entre un periodo, así como muchas otras características dependientes del tipo de datos seleccionado.

Además podemos especificar algunas características más de los datos, como el formato en el que queremos obtenerlos. Las opciones disponibles son HTML, Excel, XML, CVS y SQL. Según el formato de exportación nos preguntará el nombre de la tabla si hemos seleccionado SQL, el carácter separador si hemos seleccionado CVS y el nodo cabecera si es XML. También podemos seleccionar entre cuatro países para indicar que queremos que los datos generados guarden relación con ellos. Una lástima que España no esté entre los posibles. Como última opción podemos elegir cuantos resultados queremos obtener.

Aquí dejo un par de captura de datos que he generado, la verdad es que esta herramienta tiene una grandísima utilidad.

![Especificación de los datos](/uploads/posts/images/generatedata_especificacion.png)

![Datos generados](/uploads/posts/images/generatedata_datos.png)