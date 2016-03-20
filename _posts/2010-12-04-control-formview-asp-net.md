---
layout: post
comments: false
title: Control FormView ASP.NET
---

Un control muy potente cuando estamos desarrollando en ASP.NET es el **FormView**. Este control permite la inserción, edición y borrado de elementos en una base de datos de una forma muy simple y fácil de implementar. Vamos a mostrarlo mediante un ejemplo. Para comenzar utilizaremos una base de datos que contendrá tres tablas: *pelicula*, *director* y *genero*. La estructura de estas tablas es la que podemos ver a continuación:


Película

![Tabla Película](/uploads/posts/images/tabla_pelicula_fw.png)

Director

![Tabla Director](/uploads/posts/images/tabla_director_fw.png)

Género

![Tabla Género](/uploads/posts/images/tabla_genero_fw.png)

Además de crear las tablas también tenemos que crear las relacionaremos entre ellas, de forma que el diagrama de nuestra base de datos quedará como en la siguiente imagen.

![Diagrame Base de Datos](/uploads/posts/images/diagrama_fw.png)

Si no sabes como crear las relaciones entre las tablas, puedes darle un vistazo a la entrada de [crear relaciones en SQL Server Database](/2010/11/15/relaciones-sql-server-database.html), donde explico como realizarlo. A continuación introduciremos algunos datos para ir viendo los resultados de nuestro ejemplo. Los datos que he usado para el ejemplo los he extraído de [imdb](http://www.imdb.es/).

<!--more-->

Película:

![Datos Película](/uploads/posts/images/datos_pelicula_fw.png)

Director:

![Datos Director](/uploads/posts/images/datos_director_fw.png)

Género:

![Datos Género](/uploads/posts/images/datos_genero_fw.png)

Ahora vamos a nuestra página aspx y de la caja de herramientas arrastramos el control **FormView** hasta la ubicación donde lo queremos colocar. Una vez que lo hemos soltado, tenemos que añadir un **SqlDataSource**. Esto lo podemos realizar arrastrando de la caja de herramientas el control o accediendo con al menú contextual del **FormView** que aparece al pulsar la flecha que tiene al lado y seleccionando la opción *\<New DataSource...\>*. Si nos pregunta de donde queremos obtener los datos tenemos que seleccionar la opción *Database*. Después se abrirá el asistente de configuración del SqlDataSource, lo primero es seleccionar la cadena de conexión de donde queremos obtener los datos. La siguiente pantalla nos preguntará que datos queremos obtener, lo que haremos aquí es seleccionar la primera opción *Specify a custom SQL statement or stored procedure* y pulsaremos *Next*. En la siguiente pantalla tenemos que introducir las sentencias que queremos usar para el select, el insert, el update y el delete. Esto lo podemos hacer con el **Query Builder** pulsando el botón con su nombre o insertando el texto de las sentencias. En nuestro ejemplo quedaría de la siguiente forma:

![Sentencias SqlDataSource](/uploads/posts/images/sentencias_fw.png)

El resto de sentencias serían así:

``` sql
SELECT Pelicula.id, Pelicula.titulo, Pelicula.duracion, 
    Pelicula.sinopsis, Pelicula.director AS director_id, Director.nombre, 
    Director.apellido, Pelicula.genero AS genero_id, Genero.nombre AS genero 
FROM Pelicula LEFT OUTER JOIN Director ON Pelicula.director = Director.id 
    LEFT OUTER JOIN Genero ON Pelicula.genero = Genero.id

UPDATE Pelicula SET titulo = @titulo, duracion = @duracion, 
    genero = @genero_id, director = @director_id, sinopsis = @sinopsis 
WHERE (id = @id)

INSERT INTO Pelicula(titulo, duracion, genero, sinopsis, director) VALUES 
    (@titulo, @duracion, @genero_id, @sinopsis, @director_id)

DELETE FROM Pelicula where id = @id
```

Cuando tengamos todas las sentencias completadas pulsaremos *Next* y por último *Finish* para completar la configuración del **SqlDataSource**. Si hemos insertado el **SqlDataSource** arrastrándolo desde la caja de herramientas ahora nos quedara asociarlo al **FormView**. Esto lo podemos hacer desde el menú contextual del control **FormView** (el que sale al pulsar la flecha ![Menú](/uploads/posts/images/menu_control.png) y seleccionando el **SqlDataSource** que acabamos de crear. Una vez seleccionado, se actualizará el control **FormView** (en caso de que no se actualice pulsaremos el enlace *Refresh Schema* del menú contextual) y veremos en la vista de diseño como se mostrará el control.

![Vista inicial del control](/uploads/posts/images/control_inicial_fw.png)

Ahora vamos a modificar un poco la vista del control para dejarle un aspecto visual algo mejor. Lo primero que haremos es seleccionar el control **FormView** y cambiarle la propiedad **AllowPaging** a **True**. Después en el menú contextual del **FormView** haremos clic en al opción *Edit Templates*. Cambiará el diseño del control para que podamos editar las plantillas y a continuación modificaremos la propiedad **Text** de los tres **LinkButton** que aparecen en la parte inferior por *Editar*, *Borrar* e *Insertar*. También borraremos el texto "apellido", el texto "nombre" lo cambiaremos por "Director:" y haremos que el **Label** apellido esté en la misma línea que el nombre del director. Borraremos los siguientes campos para que no se muestren: *id*, *director_id* y *genero_id*. Después cambiamos todos los textos para ponerlos en mayúsculas y en negrita. Por último creamos una tabla con dos columnas y alojamos cada campo en su columna para que quede ordenado. Cuando terminemos, en el menú contextual pulsaremos *End Template Editing*. Si ahora ejecutamos nuestra aplicación el resultado tendrá un aspecto similar al siguiente:

![](/uploads/posts/images/plantilla_mostrar_finalizada_fw.png){:width="750px"}

Ahora pasaremos de nuevo a editar las plantillas y esta vez cuando estamos dentro de la opción editar plantilla, en el menú contextual seleccionaremos la opción *EditItemTemplate*. Creamos una tabla como antes para distribuir los datos mejor, el **Label** *id* lo cambiaremos por un **HiddenField** para evitar que al usuario se le muestre esa información y quedará de la siguiente manera:

``` none
<asp:HiddenField ID="idLabel1" runat="server" Value='<%# Eval("id") %>' />
```

Después añadiremos dos **SqlDataSource**, uno de ellos para obtener todos los directores y el otro para obtener los géneros. Comencemos con la configuración del **SqlDataSource** de directores, aquí lo que nos interesa obtener es el identificador, el nombre y el apellido de un director. Como queremos obtener el nombre y el apellido del director juntos, utilizaremos el operador de [concatenar](http://msdn.microsoft.com/en-us/library/aa276862(SQL.80).aspx) de forma que la select nos quedará así:

![SqlDataSource Director](/uploads/posts/images/sqldatasource_director_fw.png)

Por otra parte la configuración del de géneros será sencilla, simplemente seleccionaremos todos los datos que contenga:

![SqlDataSource Genero](/uploads/posts/images/sqldatasource_genero_fw.png)

Cuando los tengamos, eliminamos los **TextBox** para el nombre, apellido y género puesto que vamos a usar los **DropDownList** para facilitar la selección de estos datos. Añadimos dos **DropDownList**, uno para el género al que pondremos de nombre *DDLEditarGenero* y otro para el director que llamaremos *DDLEditarDirector*. Les asignamos a cada uno su correspondiente **SqlDataSource**, que hemos creado antes, seleccionándolo en la propiedad **DataSourceID**. Después para ambos controles indicamos en su propiedad **DataTextField** el campo *nombre* y en **DataValueField** el campo *id*, también pondremos la propiedad **AppendDataBoundItems** a *True* y en la propiedad **Items** pulsamos el icono con los tres puntos que sale al lado y añadimos una entrada. En el **DropDownList** de género indicaremos en la propiedad **Text** <em>"Seleccione un género"</em> y dejaremos la propiedad **Value** vacía, en el de directores, la propiedad **Text** será "Seleccione un director" y **Value** también vacío. A continuación vamos a la edición de código fuente y buscamos el código de los dos **DropDownList** que acabamos de crear, en ellos añadimos una nueva propiedad **SelectedValue** y le hacemos un *Bind* con los campos correspondientes que recuperemos del **SqlDataSource**. El código de los dos **DropDownList** nos quedará así:

``` html
<asp:DropDownList ID="DDLEditarGenero" runat="server" 
    DataSourceID="SqlDataSourceGeneros" DataTextField="nombre" 
    DataValueField="id" SelectedValue=''<%# Bind("genero_id") %>''
    AppendDataBoundItems="True">
        <asp:ListItem Value="" Text="Seleccione un género" />
</asp:DropDownList>

<asp:DropDownList ID="DDLEditarDirector" runat="server" 
    DataSourceID="SqlDataSourceDirectores" DataTextField="nombre" 
    DataValueField="id" SelectedValue=''<%# Bind("director_id") %>'' 
        AppendDataBoundItems="True">
            <asp:ListItem Value="" Text="Seleccione un director" />
</asp:DropDownList>
```


Ahora cambiamos los texto de los **LinkButton** por Actualizar y Cancelar, eliminamos los campos de director_id, apellidos, genero_id con sus respectivos **TextBox**, renombramos la etiqueta nombre a *Director:*, cambiamos las propiedades del **TextoBox** de sinopsis y en la propiedad **TextMode** seleccionamos *MultiLine*, por último lo organizamos todo de nuevo en una tabla.

![Editar](/uploads/posts/images/plantilla_editar_fw.png)

Si pasamos ahora a editar la plantilla **InsertItemTemplate** podemos copiar el mismo código que hemos creado en la plantilla **EditItemTempleta** con la salvedad del **HiddenField** que creamos para el id. También cambiaremos los textos de los **LinkButton** por Insertar y Cancelar.

![Insertar](/uploads/posts/images/plantilla_insertar_fw.png)

Con estos pasos ya tenemos nuestro **FormView** completamente funcional para poder insertar, editar y borrar películas en nuestra base de datos. Como hemos podido ver, de una forma sencilla hemos proporcionado muchísima funcionalidad ya que este control es muy potente. Si queréis descargar el ejemplo completo lo podéis hacer desde [aquí](/uploads/posts/samples/FormViewSample.rar).

He observado que las bases de datos creadas con la versión normal de Visual Studio no son compatibles con las version Express (gratuita), así que he creado dos bases de datos y dos formularios para que sea cual sea la versión que uses puedas ejecutar el ejemplo correctamente.