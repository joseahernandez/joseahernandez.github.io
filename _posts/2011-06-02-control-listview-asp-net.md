---
layout: post
comments: false
title: Control ListView ASP .NET
---

El ListView es un control de ASP .NET que nos permite listar y organizar de la forma que queramos los datos que recuperemos desde una base de datos, un fichero o cualquier otra fuente de datos. Este control es muy fácil de configurar y nos brinda grandes posibilidades para cambiar la apariencia en la que queremos que se muestren los datos. Vamos a ver un ejemplo de como utilízalo.

Para comenzar tenemos que crear un nuevo proyecto web ASP .NET, en mi caso los datos los voy a obtener de una base de datos local que he llamado *DBPoblaciones*. Esta base de datos únicamente tiene una tabla llamada Poblaciones en la cual tenemos el nombre, la superficie y el número de habitantes de algunas poblaciones.

<!--more-->

Una vez que tenemos la base de datos definida y con datos, abrimos el WebForm Default.aspx y arrastramos a él un control ListView y un SqlDataSource. Primero configuraremos el SqlDataSource, lo seleccionamos y en el modo de diseño pulsamos en la flecha que aparece al lado del control. Se nos abrirá un menú en el cual pulsaremos en la entrada *Configurar origen de datos...*. En la primera pantalla que aparece tenemos que seleccionar la cadena de conexión a la base de datos, posteriormente pulsaremos el botón siguiente. En la pantalla que aparezca, seleccionamos el radio button *Especificar una instrucción SQL o un procedimiento almacenado personalizado* y le damos a siguiente. Por último, en la pantalla final vamos a rellenar todas las consultas para poder tener toda la funcionalidad que nos proporciona el ListView. Para ello en cada una de las pestañas ponemos las siguientes sentencias:

``` csharp
//Pestaña select
SELECT id, nombre, superficie, habitantes FROM poblaciones

//Pestaña update
UPDATE poblaciones SET nombre = @nombre, superficie = @superficie, 
    habitantes = @habitantes WHERE  id = @id

//Pestaña insert
INSERT poblaciones (nombre, superficie, habitantes) 
    VALUES (@nombre,  @superficie, @habitantes)

//Pestaña delete
DELETE FROM poblaciones WHERE id = @id
```

La base de datos ha sido configurada de forma que la clave primaria es autoincrementable, de forma que en el insert no tenemos que tener en cuenta ese campo. Una vez que finalizamos la configuración del SqlDataSource pasamos a configurar el ListView. Seleccionamos el control en la vista de diseño y pulsamos la flecha que sale al lado del control. En el menú que aparece, donde indica *Elegir origen de datos* seleccionamos el SqlDataSource que acabamos de configurar.


En este momento ya tenemos configurado nuestro ListView, ahora tenemos que indicar el diseño con el que queremos que se muestre en pantalla, podemos hacerlo picando directamente el código o seleccionando una plantilla y modificándolo a partir de esa plantilla. En este caso voy a usar esa segunda opción así que de nuevo pincho en la flecha de al lado del control ListView y selecciono el elemento *Configurar ListView...* del menú.


En la ventana que nos aparece tenemos varias opciones para seleccionar el diseño con el que queremos mostrar el ListView. Yo he seleccionado el diseño **Mosaico** y el estilo **Profesional**. Además marco los checkbox, para habilitar la edición, la inserción, la eliminación y la paginación de los datos.

![Configuración](/uploads/posts/images/configuracion_lv.png)

Cuando finalicemos, el resultado que obtendremos será el siguiente:

![Vista inicial](/uploads/posts/images/vista_inicial_lv.png)

Como podemos ver, el diseño nos ha dividido los datos en filas y en cada fila tenemos 3 columnas. Al número de columnas lo vamos a llamar grupos y podemos cambiar el número de grupos que queremos desde la propiedad **GroupItemCount** del ListView. Si cambiamos al modo Código y miramos el código que se ha generado podemos distinguir 9 secciones dentro del ListView:

* AlternatingItemTemplate
* EditItemTemplate
* EmptyDataTemplate
* EmptyItemTemplate
* GroupTemplate
* InsertItemTemplate
* ItemTemplate
* LayoutTemplate
* SelectedItemTemplate

A continuación explicaré una a una las distintas secciones para entender cuál es la utilidad de cada una. Comencemos por la sección **LayoutTemplate**. El código que podemos ver en esta sección es el siguiente:

``` csharp
<table runat="server">
  <tr runat="server">
    <td runat="server">
      <table ID="groupPlaceholderContainer" runat="server" border="1" 
          style="background-color: #FFFFFF;border-collapse: collapse;
                 border-color: #999999;border-style:none;border-width:1px;
                 font-family: Verdana, Arial, Helvetica, sans-serif;">
        <tr ID="groupPlaceholder" runat="server">
        </tr>
      </table>
    </td>
  </tr>
  <tr runat="server">
    <td runat="server" style="text-align: center;background-color: #CCCCCC;
                               font-family: Verdana, Arial, Helvetica, 
                               sans-serif;color: #000000;">
      <asp:DataPager ID="DataPager1" runat="server" PageSize="12">
        <Fields>
          <asp:NextPreviousPagerField ButtonType="Button" 
                ShowFirstPageButton="True" ShowLastPageButton="True" />
        </Fields>
      </asp:DataPager>
    </td>
  </tr>
</table>
```

Este código muestra el diseño externo que tendrán nuestros datos. Como podemos ver se trata de una tabla que contiene dos filas y una celda cada fila. En la primera fila, hay otra tabla con una única fila en la cual se irán rellenando los datos devueltos por el SqlDataSource con el formato que indiquemos en el resto de secciones. Un detalle en el que nos tenemos que fijar es en el ID que tiene esta fila **groupPlaceholder** Antes hemos mencionado que diremos que las celdas de la fila donde se muestran los datos los llamaremos grupos y esté ID está indicando que el código que pongamos en la sección **GroupTemplate** reemplazará está fila por su contenido.

Si miramos ahora la sección **GroupTemplate** el código que contiene es el siguiente:

``` csharp
<tr ID="itemPlaceholderContainer" runat="server">
  <td ID="itemPlaceholder" runat="server">
  </td>
</tr>
```

Como hemos dicho, la fila del LayoutTemplate con el id groupPlaceHolder será remplazada por el contenido de esta sección que contiene una fila con una celda cuyo id es **itemPlaceholder**. Esta celda se repetirá tantas veces como hallamos indicado en la propiedad **GroupItemCount** del ListView. Además dentro de esa celda se pondrá el código que indiquemos en las secciones **ItemTemplate**, **AlternatingItemTemplate**, **EditItemTemplate**, **EmptyItemTemplate** y **SelectedItemTemplate**.


La siguiente sección que vamos a examinar será el **EmptyDataTemplate**. El código que indiquemos en esta sección será lo que se muestre cuando el SqlDataSource no devuelva ningún dato. En el caso actual mostrará una fila con el mensaje: "No se han devuelto datos".

``` csharp
<table runat="server" style="background-color: #FFFFFF;
    border-collapse: collapse; border-color: #999999;
    border-style:none; border-width:1px;">
  <tr>
    <td>
      No se han devuelto datos.
    </td>
  </tr>
</table>
```

Seguimos con la sección **EmptyItemTemplate** el código de esta sección se mostrará cuando tengamos datos que mostrar, pero estos no consigan rellenar todos los elementos que hemos indicado. Es decir, si recuperamos únicamente dos poblaciones se mostrarían en las dos primeras celdas y en la tercera se mostraría el código incluido en esta sección.

Continuamos con **InsertItemTemplate**, en esta sección pondremos los controles que queremos que se muestren a la hora de realizar una nueva inserción en la base de datos. Como podemos ver por defecto nos ha puesto los TextBox para rellenar todos los campos de la base de datos a excepción del id. Hay que indicar que con la propiedad del ListView **InsertItemPosition** podemos indicar si queremos que estos campos aparezcan al final del resto de elementos o al principio de todos ellos.

``` html
<td runat="server" style="" >
  nombre:
  <asp:TextBox ID="nombreTextBox" runat="server" 
    Text="<%# Bind("nombre") %>" />
  <br />superficie:
  <asp:TextBox ID="superficieTextBox" runat="server" 
            Text="<%# Bind("superficie") %>" />
  <br />habitantes:
  <asp:TextBox ID="habitantesTextBox" runat="server" 
            Text="<%# Bind("habitantes") %>" />
  <br />
  <asp:Button ID="InsertButton" runat="server" CommandName="Insert" 
            Text="Insertar" />
  <br />
  <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" 
    Text="Borrar" />
  <br />
</td>
```

Para finalizar con las secciones nos quedan los elementos **SelectedItemTemplate**, **ItemTemplate**, **EditItemTemplate** y **AlternatingItemTemplate**. Todos ellos representan los datos de los elementos, el primero indica como mostrar los datos cuando el item está seleccionado, el segundo como se representan los elementos en estado normal, el tercero en modo de edición y el cuarto si queremos hacer alguna diferencia entre elementos alternos, como se mostrarán los segundos. A excepción de la sección editar que contiene un formulario similar al de insertar, el código del resto de secciones es similar cambiando únicamente el color de fondo.

``` html
//EditItemTemplate
<td runat="server" style="background-color:#008A8C;color: #FFFFFF;">
  id:
  <asp:Label ID="idLabel1" runat="server" Text="<%# Eval("id") %>" />
  <br />nombre:
  <asp:TextBox ID="nombreTextBox" runat="server" 
        Text="<%# Bind("nombre") %>" />
  <br />superficie:
  <asp:TextBox ID="superficieTextBox" runat="server" 
           Text="<%# Bind("superficie") %>" />
  <br />habitantes:
  <asp:TextBox ID="habitantesTextBox" runat="server"  
           Text="<%# Bind("habitantes") %>" />
  <br />
  <asp:Button ID="UpdateButton" runat="server" CommandName="Update" 
           Text="Actualizar" />
  <br />
  <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" 
           Text="Cancelar" />
  <br />
</td>

//ItemTemplate
<td runat="server" style="background-color:#DCDCDC;color: #000000;">
  id:
  <asp:Label ID="idLabel" runat="server" Text="<%# Eval("id") %>" />
  <br />nombre:
  <asp:Label ID="nombreLabel" runat="server" Text="<%# Eval("nombre") %>" />
  <br />superficie:
  <asp:Label ID="superficieLabel" runat="server" 
           Text="<%# Eval("superficie") %>" />
  <br />habitantes:
  <asp:Label ID="habitantesLabel" runat="server" 
           Text="<%# Eval("habitantes") %>" />
  <br />
  <asp:Button ID="DeleteButton" runat="server" CommandName="Delete" 
           Text="Eliminar" />
  <br />
  <asp:Button ID="EditButton" runat="server" CommandName="Edit" 
           Text="Editar" />
  <br />
</td>
```

Una vez que ya conocemos todas las secciones de las que se compone el ListView, vamos a hacer algunas pequeñas modificaciones para crear un aspecto visual mejor. Comenzamos eliminando en todas las secciones la visualización del id, ya que este campo no se le debería mostrar al usuario. También borramos la etiqueta \<br /\> que separa los botones de editar y modificar en las secciones ItemTemplate, AlternatingItemTemplate y en SelectedItemTemplate. Hacemos lo mismo en la sección EditItemTemplate con los botones de actualizar y cancelar.

Después de esto el resultado final que obtenemos es como muestra la siguiente imagen:

![Resultado final](/uploads/posts/images/resultado_lv.png){:width="750px"}

Con esto, ya tenemos el ListView completamente operativo. Podemos realizar inserciones, ediciones y borrado de datos de una forma sencilla y no nos ha costado nada crearlo gracias este control. Si quieres descargar el proyecto que he utilizado para realizar esta entrada puedes obtenerlo desde [aquí](/uploads/posts/samples/ListViewSample.rar).

En esta entrada he explicado las partes que contiene un ListView y hemos visto un poco como poder personalizarlo. En la próxima entrada que realice quiero adentrarme más en la [personalización del control](/2011/06/21/personalizacion-listview.html) para que podamos ver todo el potencial que podemos obtener de él.