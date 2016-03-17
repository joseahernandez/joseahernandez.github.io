---
layout: post
comments: false
title: Control Repeater ASP.NET
date: 2010-09-25 15:00:00
---


El control **Repeater** de ASP .NET nos permite crear listas de datos aplicando una plantilla que se repetirá para todos los elementos mostrados. Este control resulta muy útil cuando queremos una mejor personalización de los datos o cuando no requerimos de tanta funcionalidad como la proporcionada por el GridView.

A continuación veremos un ejemplo de cómo podemos utilizar este control y los resultados que nos proporciona. Comenzaremos mostrando la base de datos que vamos a utilizar para este ejemplo:


<!--more-->

![Diagrama Entidad Relacion](/uploads/posts/images/ER-peliculas-repeater.png)

Como podemos ver se trata de una base de datos muy sencilla que no requiere mucha explicación, tenemos una tabla de *películas* que tiene su identificador, el nombre de la película y el año de la película. Otra tabla *géneros* que contiene el identificador y el nombre del género. Por último, está la tabla *pelicula_genero* que relaciona la película con el género al que pertenece. En este caso se ha supuesto que una película puede pertenecer a varios géneros a la vez.

Comencemos con el código ASP, lo primero que vamos a hacer es añadir un control **Repeater** y un control **SqlDataSource** a nuestra página, además los enlazaremos quedando el siguiente código:

{% highlight csharp linenos %}
<asp:repeater ID="Repeater1" runat="server" 
    DataSourceID="SqlDataSourcePeliculas">
</asp:repeater>

<asp:SqlDataSource ID="SqlDataSourcePeliculas" runat="server">
</asp:SqlDataSource>
{% endhighlight %}   

A continuación configuramos el **SqlDataSource**, seleccionamos la base de datos que hemos creado anteriormente. Cuando nos pregunte que datos queremos recuperar, seleccionamos de la tabla *películas* el nombre y el año y continuamos hasta la finalización del asistente. El **Repeater** es un control que no se puede editar visualmente, así que los siguientes pasos los tendremos que hacer desde la edición de código. Dentro de las etiquetas del control escribimos lo siguiente:

{% highlight csharp linenos %}
<asp:repeater ID="Repeater1" runat="server" 
    DataSourceID="SqlDataSourcePeliculas">
  <HeaderTemplate>
    <ul>
  </HeaderTemplate>

  <ItemTemplate>
    <li>
      <%# DataBinder.Eval(Container.DataItem, "titulo") %> 
      (<%# DataBinder.Eval(Container.DataItem, "anyo") %>)
    </li>
  </ItemTemplate>

  <FooterTemplate>
    </ul>
  </FooterTemplate>
</asp:repeater>
{% endhighlight %}  


El código HTML o ASP que encerremos entre las etiquetas **&lt;HeaderTemplate&gt;&lt;/HeaderTemplate&gt;** se ejecutará una vez y renderizará en pantalla lo que contenga. En nuestro caso la etiqueta de apertura de una lista, estás etiquetas se suelen usar para poner una cabecera a los datos que vienen a continuación. Como se puede imaginar el código de las etiquetas **&lt;FooterTemplate&gt;&lt;/FooterTemplate&gt;** tendrán el mismo comportamiento que el **HeaderTemplate**, pero en esa ocasión se utilizará para el pie de los datos. En nuestro caso cerrar la lista. Por último nos queda la etiqueta **ItemTemplate**, lo que aparezca entre ella se renderizará una vez por cada elemento que contenga el resultado del DataSource que le hemos asociado.


La línea, **DataBinder.Eval(Container.DataItem, "titulo")** se encarga de recuperar del DataSource asociado el ítem con la etiqueta título. Por lo tanto en el ejemplo deveolverá el título de la película y el año de esta. Hay que tener en cuenta que tanto las secciones **HeaderTemplate**, como **FooterTemplate** se ejecutarán aunque el DataSource asociado no recupere ningún dato, por el contrario la sección **ItemTemplate** únicamente se ejecutará si existen datos.

El resultado que veremos por pantalla será el siguiente:

![Resultado Repeater](/uploads/posts/images/Resultado-repeater-simple.png)

Ahora vayamos un paso más lejos, supongamos que queremos organizar todas las películas que tenemos según su género. Lo que tendríamos que hacer es seleccionar todos los géneros y después todas las películas pertenecientes a ese género. La forma de hacerlo será usando un **Repeater** anidado dentro de otro. Pasemos a ver cómo nos queda el código en esta ocasión:

{% highlight csharp linenos %}
<asp:repeater ID="RepeaterGeneros" runat="server" 
    DataSourceID="SqlDataSourceGeneros" 
  onitemdatabound="RepeaterGeneros_ItemDataBound">
  <ItemTemplate>
    <h2><%# DataBinder.Eval(Container.DataItem, "nombre") %></h2>
    
    <asp:Repeater ID="RepeaterPeliculas" runat="server">
      <HeaderTemplate>
        <ul>
      </HeaderTemplate>
      
      <ItemTemplate>
        <li>
          <%# DataBinder.Eval(Container.DataItem, "titulo") %> 
          (<%# DataBinder.Eval(Container.DataItem, "anyo") %>)
        </li>
      </ItemTemplate>
      
      <FooterTemplate>
        </ul>
      </FooterTemplate>
    </asp:Repeater>
  </ItemTemplate>
</asp:repeater>

<asp:SqlDataSource ID="SqlDataSourceGeneros" runat="server" 
  ConnectionString="<%$ ConnectionStrings:ConnectionPeliculas %>" 
  SelectCommand="SELECT [id], [nombre] FROM [generos]">
</asp:SqlDataSource>
{% endhighlight %}  


Lo primero que ha cambiado ha sido la sentencia del **SqlDataSource**, en esta ocasión seleccionamos todos los tipos de géneros que hay en nuestra base de datos. El **Repeater** mas externo, RepeaterGeneros, no contiene ni **HeaderTemplate** ni **FooterTemplate**, únicamente existe un **ItemTemplate** en el cual recuperamos el nombre del género y lo mostramos. Posteriormente creamos otro **Repeater**, RepeaterPeliculas, dentro del **ItemTemplate** y en esta ocasión le ponemos como antes una cabecera, un pie y los ítems. Por último capturaremos el evento **onitemdatabound** del RepeaterGeneros que se lanzará cada vez que se añada un nuevo ítem, es decir, un nuevo género. Lo que haremos en este evento es lo siguiente:

{% highlight csharp linenos %}
protected void RepeaterGeneros_ItemDataBound(
    object sender, RepeaterItemEventArgs e)
{
  if (e.Item.ItemType == ListItemType.Item || 
    e.Item.ItemType == ListItemType.AlternatingItem)
  {
    // Recuperamos el id del genero actual
    string generoId = ((System.Data.DataRowView)(e.Item.DataItem))
        .Row["id"].ToString();

    // Creamos la sentencia para recupera las películas del genero actual
    string selectCommand = "SELECT p.titulo, p.anyo FROM peliculas p " +
        "INNER JOIN pelicula_genero pg on (p.id = pg.pelicula_id) WHERE " +
        "pg.genero_id = " + generoId;

    // Creamos un SqlDataSource que enlazaremos al Repeater anidado
    SqlDataSource dataSourcePeliculas = new SqlDataSource(System.Configuration.
      ConfigurationManager.ConnectionStrings["ConnectionPeliculas"].ToString(), 
      selectCommand);

    // Ahora tenemos que encontrar el Repeater que tenemos dentro 
    // del ItemTemplate
    System.Web.UI.WebControls.Repeater rp = (e.Item
        .FindControl("RepeaterPeliculas") as 
        System.Web.UI.WebControls.Repeater);
    
    rp.DataSource = dataSourcePeliculas;
    rp.DataBind();
  }
}
{% endhighlight %}  


Lo primero es comprobar que estamos tratando un ítem normal, lo que quiere decir que ni es la cabecera, ni el pie, ni otro tipo de ítem. Simplemente un ítem. Posteriormente obtenemos el id del genero actual, creamos un **SqlDataSource** y lo asociamos al RepeaterPeliculas. El resultado que obtenemos después de esto es el siguiente:

![Resultado Repeater Anidado](/uploads/posts/images/Resultado-repeater-anidado.png)

Esta bastante bien, pero aún podemos mejorarlo un poco. Si nos damos cuenta el género Terror no contiene ninguna película y supongamos que en el resultado, no queremos que me salgan géneros que no contienen películas. Para ello modificaríamos el evento **onitemdatabound** y lo dejaríamos de la siguiente forma:

{% highlight csharp linenos %}
protected void RepeaterGeneros_ItemDataBound(
    object sender, RepeaterItemEventArgs e)
{
  if (e.Item.ItemType == ListItemType.Item || 
    e.Item.ItemType == ListItemType.AlternatingItem)
  {
    // Recuperamos el id del genero actual
    string generoId = ((System.Data.DataRowView)(e.Item.DataItem))
        .Row["id"].ToString();

    // Creamos la sentencia para recupera las películas del genero actual
    string selectCommand = "SELECT p.titulo, p.anyo FROM peliculas p " +
        "INNER JOIN pelicula_genero pg on (p.id = pg.pelicula_id) WHERE " +
        "pg.genero_id = " + generoId;

    // Creamos un SqlDataSource que enlazaremos al Repeater anidado
    SqlDataSource dataSourcePeliculas = new SqlDataSource(System.Configuration.
      ConfigurationManager.ConnectionStrings["ConnectionPeliculas"].ToString(), 
      selectCommand);

    // Ahora tenemos que encontrar el Repeater que tenemos dentro 
    // del ItemTemplate
    System.Web.UI.WebControls.Repeater rp = (e.Item
        .FindControl("RepeaterPeliculas") as 
        System.Web.UI.WebControls.Repeater);
    
    rp.DataSource = dataSourcePeliculas;
    rp.DataBind();

    // Comprobamos si hay películas
    if (rp.Items.Count == 0)
      e.Item.Visible = false;
  }
}
{% endhighlight %}  

Hemos añadido una condición al final que comprueba si existen películas de ese género, en caso de no existir oculta el género y no se visualiza en el resultado final.

Aquí termina esta entrada sobre el control Repeater de ASP.NET, espero que aunque sea un ejemplo muy sencillo pueda resultar de utilidad. Si quieres descargar el proyecto completo del ejemplo puedes realizarlo pinchando [aquí](/uploads/posts/samples/Repeater.rar).



