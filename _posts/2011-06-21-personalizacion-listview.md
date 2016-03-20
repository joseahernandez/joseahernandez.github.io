---
layout: post
comments: false
title: Personalización de un ListView
---

En la entrada anterior referente al [uso del ListView](/2011/06/02/control-listview-asp-net.html) comenté que realizaría una nueva, para mostrar como se puede personalizar este control. Ahora ha llegado el momento de ver como podemos realizar esta personalización. El ejemplo que voy a desarrollar es muy sencillo, únicamente quiero mostrar donde y como tenemos que modificar el código para poder mostrar los elementos como nosotros queramos. El resultado final será el siguiente:

<!--more-->

![ListView personalizado 1](/uploads/posts/images/final1-ListView2.png){:width="750px"}

![ListView personalizado 2](/uploads/posts/images/final2-ListView2.png){:width="750px"}

Como se puede ver es bastante similar al que genera automáticamente el ListView, simplemente he centrado algunos componentes y he cambiado todo el código para que en vez de utilizar tablas para dar el formato se utilicen divs. Lo primero que he realizado ha sido borrar la sección **SelectedItemTemplate** porque no voy a permitir que se seleccionen elementos. A continuación modifico la sección **LayoutTemplate** que quedará de la siguiente forma:

``` csharp
<asp:Panel runat="server">
  <asp:Panel runat="server" ID="groupPlaceHolder">
  </asp:Panel>

  <asp:Panel runat="server" HorizontalAlign="Center">
    <asp:DataPager ID="DataPager2" runat="server" PageSize="12">
      <Fields>
        <asp:NextPreviousPagerField ButtonType="Button" 
            ShowFirstPageButton="True" ShowLastPageButton="True" />
      </Fields>
    </asp:DataPager>
  </asp:Panel>
</asp:Panel>
```

Tenemos un panel con el id **groupPlaceHolder** donde se irán insertando todos los elementos que se recuperen de la base de datos. A continuación de ese panel tenemos otro, en el que se sitúa el **DataPager** para que paginemos los resultados obtenidos.

La sección **GroupTemplate** será así:

``` csharp
<asp:Panel runat="server" ID="itemPlaceholder">
</asp:Panel>
<div style="clear: both;"/>
```

Tenemos un panel con el id **itemPlaceholder** en el que se insertarán los items recuperados y posteriormente tenemos un div con el estilo **clear: both;** esto hará que cada 3 elementos (propiedad del ListView **GroupItemCount** que ponemos con el valor 3) aparezca este div haciendo que la ubicación de los elementos vuelva a ser normal. Esto lo hacemos porque a los items les pondremos el estilo **float: left;** para que aparezcan en una línea horizontal uno detrás de otro hasta que tengamos 3 items. Posteriormente tendremos este div que hará que los nuevos items que vengan se inserten a partir de una fila nueva.


Veamos ahora las secciones **ItemTemplate**, **AlternatingItemTemplate** y **EditItemTemplate**. Estas secciones son prácticamente iguales.

``` csharp
<ItemTemplate>
  <asp:Panel runat="server" BackColor="Azure" style="float: left;width:33%">
    Nombre: <asp:Label ID="Label1" runat="server" 
        Text="<%# Eval("nombre") %>" />
    <br />
    Superficie: <asp:Label ID="Label2" runat="server" 
          Text="<%# Eval("superficie") %>" />
    <br />
    Habitantes: <asp:Label ID="Label3" runat="server" 
          Text="<%# Eval("habitantes") %>" />
    <br /> 

    <div style="text-align: center">     
      <asp:Button ID="Button1" runat="server" CommandName="Delete" 
        Text="Eliminar" />
      <asp:Button ID="Button2" runat="server" CommandName="Edit" 
        Text="Editar" />
    </div>                  
  </asp:Panel>
</ItemTemplate>

<AlternatingItemTemplate>
  <asp:Panel runat="server" BackColor="Beige" style="float: left; width:33%">
    Nombre: <asp:Label ID="Label1" runat="server" 
        Text="<%# Eval("nombre") %>" />
    <br />
    Superficie: <asp:Label ID="Label2" runat="server" 
          Text="<%# Eval("superficie") %>" />
    <br />
    Habitantes: <asp:Label ID="Label3" runat="server" 
          Text="<%# Eval("habitantes") %>" />
    <br />  
                    
    <div style="text-align: center">  
      <asp:Button ID="Button1" runat="server" CommandName="Delete" 
        Text="Eliminar" />
      <asp:Button ID="Button2" runat="server" CommandName="Edit" 
        Text="Editar" />
    </div>
  </asp:Panel>
</AlternatingItemTemplate>

<EditItemTemplate>
  <asp:Panel ID="Panel1" runat="server" BackColor="Bisque" 
       style="float: left;width:33%">
    Nombre:
    <asp:TextBox ID="nombreTextBox" runat="server" 
        Text="<%# Bind("nombre") %>" />
    <br />
    Superficie:
    <asp:TextBox ID="superficieTextBox" runat="server" 
         Text="<%# Bind("superficie") %>" />
    <br />
    Habitantes:
    <asp:TextBox ID="habitantesTextBox" runat="server" 
         Text="<%# Bind("habitantes") %>" />
    <br />

    <div style="text-align: center">  
      <asp:Button ID="UpdateButton" runat="server" CommandName="Update" 
           Text="Actualizar" />
      <asp:Button ID="CancelButton" runat="server" CommandName="Cancel" 
           Text="Cancelar" />
    </div>
  </asp:Panel>
</EditItemTemplate>
```

ItemTemplate y AlternatingItemTemplate únicamente se diferencian en el color usado de fondo. EditItemTemplate se diferencia de las otras dos secciones en que utiliza controles TextBox en vez de Label y sus botones realizan otras acciones distintas. Como he indicado antes, las tres secciones contienen el estilo **float: left** además de **width: 33%** para que ocupen entre las tres columnas todo el ancho del elemento que los contiene.

La última sección importante que nos queda es InsertItemTemplate que quedaría así:

``` csharp
<InsertItemTemplate>
  <div style="clear: both;" />
  <br />
  <asp:Panel runat="server" HorizontalAlign="Center">
    Nombre: 
    <asp:TextBox ID="nombreTextBox" runat="server" 
        Text="<%# Bind("nombre") %>" />
    Superficie: 
    <asp:TextBox ID="superficieTextBox" runat="server"
         Text="<%# Bind("superficie") %>" />
    Habitantes: 
    <asp:TextBox ID="habitantesTextBox" runat="server"
         Text="<%# Bind("habitantes") %>" />
                    
    <asp:Button ID="InsertButton" runat="server" CommandName="Insert"
         Text="Insertar" />
  </asp:Panel>
  <br />
</InsertItemTemplate>
```

Lo primero que contiene esta sección es un div con el estilo **clear: both**, esto lo realizo para asegurarme de que aunque quede una columna de las tres posibles para los items sin rellenar, la sección InsertItemTemplate comience en una nueva línea. También pongo dos saltos de línea antes y después de los controles para que quede más separado y dentro del panel pongo los controles necesarios para insertar un nuevo item.

Para finalizar, las secciones **EmptyDataTemplate** y **EmptyItemTemplate** quedarán así:

``` csharp
<EmptyDataTemplate>
  <asp:Panel runat="server">
    No se han devuelto datos.
  </asp:Panel>
</EmptyDataTemplate>

<EmptyItemTemplate>
  <asp:Panel ID="Panel2" runat="server" style="float: left;width:33%">
  </asp:Panel>
</EmptyItemTemplate>
```

No creo que haya que explicar mucho de ellas, simplemente muestran el mensaje indicado cuando no hay datos o un panel en blanco cuando falta un item para rellenar las 3 columnas que tenemos.

Como hemos podido ver, de una forma sencilla hemos podido personalizar el control ListView. Por lo tanto podemos observar que además de ser un control muy potente que nos permite muchos usos, también es muy fácil personalizarlo a nuestro gusto. Si quieres ver el código completo, podéis descargar el proyecto desde [aquí](/uploads/posts/samples/ListViewSample2.rar)