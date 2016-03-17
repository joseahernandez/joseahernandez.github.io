---
layout: post
comments: false
title: Crear relaciones en SQL Server Database
---

Cuando desarrollamos aplicaciones en .NET tanto si son aplicaciones de escritorio como aplicaciones web, el IDE Visual Studio nos proporciona un tipo de base de datos que podemos utilizar de forma rápida y sencilla (Sql Server Database). Para añadir esta base de datos en un proyecto web, simplemente hacemos clic derecho encima del nombre del proyecto, vamos a la entrada de menú *Add* y seleccionamos *New Item*. En el árbol de la izquierda que nos aparece seleccionamos la plantilla *Data* y en la ventana de la derecha *SQL  Server Database*, le ponemos el nombre que queramos y pulsamos el botón añadir.

![Añadir base de datos](/uploads/posts/images/add_database.png)

La base de datos aparecerá en nuestro proyecto y si hacemos doble clic encima de ella se nos abrirá la ventana del explorador de base de datos. En el explorador es donde crearemos las tablas, vistas, relaciones,... e insertaremos los datos en las tablas. 

![Explorador base de datos](/uploads/posts/images/server_explorer.png)

Cuando desarrollamos aplicaciones en .NET tanto si son aplicaciones de escritorio como aplicaciones web, el IDE Visual Studio nos proporciona un tipo de base de datos que podemos utilizar de forma rápida y sencilla (Sql Server Database). Para añadir esta base de datos en un proyecto web, simplemente hacemos clic derecho encima del nombre del proyecto, vamos a la entrada de menú *Add* y seleccionamos *New Item*. En el árbol de la izquierda que nos aparece seleccionamos la plantilla *Data* y en la ventana de la derecha *SQL  Server Database*, le ponemos el nombre que queramos y pulsamos el botón añadir.

![Añadir base de datos](/uploads/posts/images/add_database.png)

La base de datos aparecerá en nuestro proyecto y si hacemos doble clic encima de ella se nos abrirá la ventana del explorador de base de datos. En el explorador es donde crearemos las tablas, vistas, relaciones,... e insertaremos los datos en las tablas. 

![Explorador base de datos](/uploads/posts/images/server_explorer.png)
 
<!--more-->

Para comenzar crearemos las tablas que necesitemos en nuestro proyecto, para ello hacemos clic derecho encima de la carpeta *Tablas* y seleccionamos la opción *Add New Table*. Se nos abrirá una  ventana donde vamos a definir las columnas de nuestra tabla. En mi caso he definido las siguientes columnas con los siguientes tipos:

![Tabla autor](/uploads/posts/images/tabla_autor.png)

Posteriormente hacemos clic derecho encima de la fila *id* y seleccionamos la entrada *Set Primary Key*. Por último en la parte inferior de la ventana donde pone *Column Properties* y teniendo marcada la fila id, expandimos la propiedad *Identity Specification* y en la propiedad *(Is Identity)* seleccionamos *Yes*. Con esto conseguiremos que la columna se autoincremente conforme vamos añadiendo nuevos datos. Para finalizar guardamos la tabla y le ponemos de nombre *Autor*.

A continuación crearemos otra tabla del mismo modo que hemos hecho antes, esta vez las columnas serán las siguientes:

![Tabla libro](/uploads/posts/images/tabla_libro.png)

Volvemos a seleccionar la fila *id* como clave primaria y hacemos que se autoincremente. Esta tabla la llamaremos *Libro*.

Ahora vamos a **definir las relaciones** entre las tablas. Para ello en el explorador hacemos clic derecho encima de la carpeta *Database Diagrams* y añadimos un nuevo diagrama. Si nos aparece un cuadro de dialogo haciéndonos una pregunta respondemos que si que queremos crear los objetos necesarios para el diagrama. Se nos abrirá una ventana en blanco y nos aparecerá el cuadro para seleccionar las tablas, en caso de no aparecer hacemos clic derecho en la ventana blanca y seleccionamos la opción *Add Tables...*. Seleccionamos las dos tablas que hemos creado y le damos a *Add*, una vez que tengamos las dos en la ventana principal cerramos la ventana de añadir tablas.

Para definir la relación entre las dos tablas hacemos clic en la columna *id* de la tabla *Autor* y la arrastramos hasta la columna *autor* de la tabla *Libro*. Se mostrará una ventana preguntándonos que nombre queremos ponerle a la relación (lo dejaremos por defecto)  y especificándonos las tablas y las columnas de la relación. Si todos es correcto pulsamos en *Ok*. En la siguiente ventana que aparece podemos definir algunas propiedades más de la relación y después pulsaremos en *Ok*. Al finalizar el diagrama nos quedará de la siguiente manera:

![Diagrama](/uploads/posts/images/diagrama.png)

Con esto ya tenemos nuestro ejemplo de relaciones en la base de datos y ahora podemos comenzar a insertar datos. Para ello en el *explorador de bases de datos* haremos clic derecho encima de la tabla que queramos insertar los datos y seleccionaremos la entrada de menú *Show Table Data*.
