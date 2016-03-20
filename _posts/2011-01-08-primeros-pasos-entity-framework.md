---
layout: post
comments: false
title: Primeros pasos con Entity Framework
---

Entity Framework es un modelo de acceso a datos en el que se utiliza la técnica [ORM](http://localhost:1453/Depuradoras/Index.aspx?res=timeout). El ORM se basa en mapear las tablas de la base de datos en objetos para conseguir una forma sencilla de trabajar y de comunicarse con ella. Actualmente la última versión que ha sido publicada es la 4.0 que viene con el .NET Framework 4.0.

 
A continuación veremos un pequeño ejemplo de como utilizar Entity Framework en una aplicación. Lo primero que haremos será crear un nuevo proyecto de tipo **Windows Forms Application**, a continuación cuando tengamos el proyecto creado iremos al **Explorador de soluciones** y haremos clic derecho encima del nombre del proyecto para añadir un elemento nuevo. Seleccionaremos la opción **Service-based Database** y le pondremos de nombre **Agenda**. En la siguiente ventana que nos aparezca seleccionaremos la opción **Entity Data Model** y pulsaremos el botón Next. Posteriormente, seleccionaremos la opción **Empty model** y pulsamos Finish. Cuando hayamos finalizado tendremos creada una base de datos local y un modelo de datos que se llamará **Model1.edmx**.

 
Entity Framework se puede usar con muchos gestores de bases de datos distintos: Sql Server, MySql, Sqlite... como en nuestro ejemplo usaremos Entity Framework con una base de datos local, hemos añadido el modelo de datos y la base de datos a la vez. Si quisiéramos crear el modelo para una base de datos ya existente, en la opción de añadir un elemento al proyecto seleccionaríamos la opción **ADO.NET Entity Data Model**.

 
Vamos a comenzar definiendo el modelo de datos. Lo primero que haremos será cambiar el nombre al fichero del modelo a **ModeloAgenda**. Después abrimos el fichero y desde la caja de herramientas arrastramos dos objetos de tipo **Entity** a la ventana de diseño. Haciendo doble clic en los título de los objetos podremos modificar su nombre, a uno lo llamaremos **Contacto** y a otro **Telefono**. Ahora seleccionamos el objeto que hemos llamado **Contacto** y hacemos clic derecho encima de él, vamos al menú **Add** y en el submenú que aparece seleccionamos **Scalar Property**. Se creará una nueva propiedad en el objeto a la que llamaremos **Nombre**, volveremos a repetir el proceso y crearemos una nueva propiedad llamada **Apellidos**. Cuando acabemos vamos a **Telefono** y añadimos las propiedades **Descripcion** y **Numero**. Si seleccionamos la propiedad **Numero** y vamos a su cuadro de propiedades vemos que hay una propiedad llamada **Type** en la cual vamos a seleccionar el valor **Int32** para indicar cual es su tipo. A continuación, hacemos clic derecho en cualquier sitio en blanco dentro de la ventana de diseño, vamos de nuevo al menú **Add** y pulsamos la opción **Association**. La ventana que aparece la configuraremos para que tenga los mismos datos que la siguiente imagen:

![Asociación](/uploads/posts/images/Asociacion_EF.png)

<!--more-->
  
Cuando finalicemos pulsaremos el botón Ok y tendremos nuestro modelo de datos finalizado y con un aspecto como este:

![Modelo de datos](/uploads/posts/images/modelo_datos_EF.png)
 
Antes de terminar con el diseño del modelo, seleccionaremos el objeto **Contacto** y en su propiedad **Entity Set Name** pondremos **Contacto**, para **Telefono** haremos lo mismo poniendo **Telefono** en la propiedad. Con esto indicamos que estos son los nombres que queremos para las tablas que posteriormente se generaran. Después haremos clic izquierdo en cualquier espacio en blanco de la ventana de diseño e iremos a las propiedades, en ellas pondremos en la propiedad **Entity Container Name** **AgendaContext**. Para finalizar con el modelo, seleccionaremos la línea que conecta nuestros dos objetos y en su propiedad **End1 OnDelete** seleccionaremos la opción **Cascade**.
 
El siguiente paso será crear la base de datos, para ello hacemos clic derecho de nuevo en cualquier sitio en blanco en la ventana de diseño y seleccionamos la opción **Generate Database from Model**. Nos aparecerá una ventana para seleccionar la conexión a la base de datos que queremos utilizar. Como hemos creado conjuntamente la base de datos con el modelo, por defecto nos aparecerá seleccionada la conexión a la base de datos y simplemente tendremos que pulsar el botón Next. La ventana que nos aparezca muestrará el código sql que se va a generar, simplemente tenemos que pulsar en Finish. A continuación, se abrirá un fichero llamado **ModeloAgenda.edmx.sql** que contiene todos los scripts que debemos ejecutar para generar la base de datos (en caso de que no se haya abierto, lo podemos abrir buscándolo en el explorador de soluciones).

Lo siguiente será hacer doble clic en el fichero de base de datos **Agenda.mdf** de forma que se abrirá en el explorador de base de datos.

![Explorador base de datos](/uploads/posts/images/explorador_basedatos_EF.png)
 
Pulsamos clic derecho encima del nombre de la base de datos y seleccionamos la entrada del menú **New Query** para que aparezca el generador de consultas. Cerramos la primera ventana que aparece, ya que no utilizaremos ninguna tabla y ocultaremos todos los paneles excepto el de sql  que es el único que nos interesa. Esto lo haremos desmarcando todas las opciones menos la de Sql en la barra de herramientas:

![Barra herramientas de consultas](/uploads/posts/images/barra_herramientas_query_EF.png)
 
Ahora copiaremos los scripts que se generaron antes, pero antes tenemos que tener en cuenta unas cosas. Los scripts creados finalizan con la sentencia GO que no está soportada por el tipo de base de datos que vamos a usar, por lo tanto eliminaremos todas las líneas donde aparezca dicha sentencia. A la hora de ejecutar los scripts lo haremos en tres pasos, primero la creación de las tablas, después la creación de claves primarias y por último la creación de claves ajenas. Teniendo en cuenta estos pasos procederemos a ejecutar los scripts. El resultado será la creación de las tablas que podremos ver así:

![Tablas en Explorador de base de datos](/uploads/posts/images/explorador_basedatos_tablas_EF.png)

Ahora crearemos la interfaz para manejar nuestra aplicación. No voy a describir este proceso ya que esta fuera del alcance de este ejemplo. Simplemente he añadido dos ListView, en uno tendré los nombres y apellidos de los contactos y en el otro, cuando seleccione un contacto, aparecerán los números de teléfono que tiene ese contacto. Además, he incluido los botones para insertar, editar y eliminar tanto contactos como teléfonos. El aspecto de la interfaz es como la siguiente imagen:

![Interfaz de la aplicación](/uploads/posts/images/gui_aplicacion_EF.png)
  
Ahora nos centraremos en los métodos que usamos para consultar, insertar, editar y eliminar los datos con la ayuda del modelo que hemos creado. Lo primero será consultar los datos de la base de datos para que una vez que arranque la aplicación cargue todos los contactos disponibles. Para realizar esta tarea en el evento **Form1_Load** llamaremos al método **CargarContactos**. El código de este método será el siguiente:
 
``` csharp
private void CargarContactos()
{
  // Limpiamos el ListView de los contactos
  listViewContactos.Items.Clear();
 
  // Instanciamos el modelo que hemos creado antes
  using (var contexto = new AgendaContext())
  {
    // Usando LinQ consultamos todos los contactos existen
    var contactos = from contac in contexto.Contacto
                    select contac;
 
    // Recorremos todos los contactos que hemos obtenido en la consulta y 
    // relleno el ListView
    foreach (Contacto c in contactos)
    {
      ListViewItem item = new ListViewItem(c.Nombre);
      item.SubItems.Add(c.Apellidos);
      item.SubItems.Add(c.Id.ToString());
      listViewContactos.Items.Add(item);
    }
  }
}
```
 
El código creo que es bastante claro, pero resumiendo, toda la funcionalidad de acceso a la base de datos la lleva a cabo el objeto **AgendaContext** sobre el cual aplicamos la select en [LinQ](http://msdn.microsoft.com/en-us/netframework/aa904594). Un punto fuerte de LinQ es que nos ayuda con intellisense a realizar la consulta y que realiza la comprobación de esta en tiempo de compilación, con lo que no tendremos que estar ejecutando la aplicación constantemente para saber si hemos escrito correctamente la sentencia.
 
Antes de mostrar los métodos que se encargan de insertar, editar y eliminar un contacto vamos a ver el formulario que he creado para facilitar esta tarea:

![Formulario de contactos](/uploads/posts/images/formulario_contacto_EF.png)
 
Es un formulario bastante básico, simplemente tiene dos campos para poder indicar el nombre y los apellidos del contacto. Además uno de sus constructores permite que se le pasar dos parámetros para que inicialice los campos del nombre y apellidos con los valores pasados, de esta forma también nos servirá para editar los datos.

Ahora es el momento de ver el método que se ejecuta al lanzarse el evento **Click** del botón de crear un nuevo contacto:

``` csharp
private void bNuevoContacto_Click(object sender, EventArgs e)
{
  // Creamos una instancia del formulario de gestion de contacto
  using (GestionContacto gcForm = new GestionContacto())
  {
    if (gcForm.ShowDialog() == DialogResult.OK)
    {
      // Si el formulario devuelve OK creamos un nuevo contacto
      Contacto c = Contacto.CreateContacto(0, gcForm.Nombre, gcForm.Apellidos);
 
      using (var contexto = new AgendaContext())
      {
        // Lo añadimos al contexto
        contexto.Contacto.AddObject(c);
        // Salvamos el estado actual del contexto
        contexto.SaveChanges();
      }
 
      // Llamamos al metodo para cargar de nuevo los contactos
      CargarContactos();
 
      MessageBox.Show("Contacto guardado correctamente", "Guardar contacto", 
         MessageBoxButtons.OK, MessageBoxIcon.Information);
 
    }
  }
}
```

Abrimos el formulario antes mencionado para solicitar el nombre y el apellido del contacto. Cuando se pulsa en el botón Aceptar se crea una instancia de **Contacto** y con la clase **AgendaContext** añadimos ese nuevo objeto a la colección de contactos, para finalizar guardamos los cambios y cargamos de nuevo los contactos.
 
El método que se ejecuta para el evento del botón editar contacto es muy similar al anterior, su código es este:
 
``` csharp
private void bEditarContacto_Click(object sender, EventArgs e)
{
  if (listViewContactos.SelectedItems.Count > 0)
  {
    using (GestionContacto gcForm = new GestionContacto(listViewContactos.
                                                SelectedItems[0].Text,
              listViewContactos.SelectedItems[0].SubItems[1].Text))
    {
      if (gcForm.ShowDialog() == DialogResult.OK)
      {
        using (var contexto = new AgendaContext())
        {
          int id = Int32.Parse(listViewContactos.SelectedItems[0]
            .SubItems[2].Text);
          Contacto con = (from cont in contexto.Contacto
                          where cont.Id == id
                          select cont).Single();
 
          con.Nombre = gcForm.Nombre;
          con.Apellidos = gcForm.Apellidos;
 
          contexto.SaveChanges();
        }
 
        CargarContactos();
 
        MessageBox.Show("Contacto editado correctamente", 
            "Editar contacto", MessageBoxButtons.OK, 
            MessageBoxIcon.Information);
      }
    }
  }
}
```

Volvemos a usar el formulario anterior pero esta vez en el constructor le pasamos el nombre y los apellidos del contacto que se ha seleccionado en el ListView. Cuando modificamos los datos y pulsamos el botón aceptar, lo que hacemos es obtener el id del contacto que está seleccionado. El id si recuerdas el método **CargarContactos** lo hemos almacenado en el subitem 2, por lo tanto lo recuperamos de esa posición. Una vez obtenido, realizamos otra consulta en la  cual obtenemos el **Contacto** que tiene ese id. Posteriormente modificamos sus propiedades nombre y apellidos con los datos del formulario y guardamos los cambios.

El método para el evento evento del botón eliminar un Contacto es el siguiente:
 
``` csharp 
private void bEliminarContacto_Click(object sender, EventArgs e)
{
  if (listViewContactos.SelectedItems.Count > 0)
  {
    if (MessageBox.Show("¿Seguro que quiere eliminar el contacto seleccionado?", 
             "Eliminar contacto", MessageBoxButtons.YesNo, 
                MessageBoxIcon.Question)
                        == DialogResult.Yes)
    {
      using (var contexto = new AgendaContext())
      {
        int id = Int32.Parse(listViewContactos.SelectedItems[0]
            .SubItems[2].Text);
        Contacto con = (from c in contexto.Contacto
                        where c.Id == id
                        select c).Single();
 
        contexto.Contacto.DeleteObject(con);
 
        contexto.SaveChanges();
      }
 
      CargarContactos();
      MessageBox.Show("Contacto eliminado correctamente", "Eliminar contacto", 
         MessageBoxButtons.OK, MessageBoxIcon.Information);
    }
  }
}
```
 
Simplemente obtenemos el id del Contacto seleccionado, lo recuperamos con una consulta, lo eliminamos y guardamos los cambios.
 
Los métodos para los eventos de los botones de teléfonos son muy similares a los visto antes, a continuación pongo su código:

``` csharp  
private void bNuevoTelefono_Click(object sender, EventArgs e)
{
  if (listViewContactos.SelectedItems.Count > 0)
  {
    using (GestionTelefono gtForm = new GestionTelefono())
    {
      if (gtForm.ShowDialog() == DialogResult.OK)
      {
        using (var contexto = new AgendaContext())
        {
          int idContacto = Int32.Parse(listViewContactos.SelectedItems[0]
            .SubItems[2].Text);
 
          Telefono t = Telefono.CreateTelefono(0, gtForm.Descripcion, 
            int.Parse(gtForm.Numero), idContacto);
 
          contexto.Telefono.AddObject(t);
 
          contexto.SaveChanges();
        }
 
        CargarTelefonos();
        MessageBox.Show("Teléfono guardado correctamente", "Guardar teléfono", 
           MessageBoxButtons.OK, MessageBoxIcon.Information);
      }
    }
  }
}
 
private void bEditarTelefono_Click(object sender, EventArgs e)
{
  if (listViewTelefonos.SelectedItems.Count > 0)
  {
    using (GestionTelefono gtForm = new GestionTelefono(listViewTelefonos.
                                     SelectedItems[0].Text, 
                       listViewTelefonos.SelectedItems[0].SubItems[1].Text))
    {
      if (gtForm.ShowDialog() == DialogResult.OK)
      {
        using (var contexto = new AgendaContext())
        {
          int idTelefono = int.Parse(listViewTelefonos.SelectedItems[0]
            .SubItems[2].Text);
                          Telefono tel = (from t in contexto.Telefono
                          where t.Id == idTelefono
                          select t).Single();
 
          tel.Descripcion = gtForm.Descripcion;
          tel.Numero = int.Parse(gtForm.Numero);
 
          contexto.SaveChanges();
        }
        CargarTelefonos();
        MessageBox.Show("Teléfono editado correctamente", "Editar teléfono", 
           MessageBoxButtons.OK, MessageBoxIcon.Information);
      }
    }
  }
}
 
private void bEliminarTelefono_Click(object sender, EventArgs e)
{
  if (listViewTelefonos.SelectedItems.Count > 0)
  {
    if (MessageBox.Show("¿Seguro que quiere eliminar el teléfono seleccionado?"
                        ,"Eliminar telefono", MessageBoxButtons.YesNo, 
                            MessageBoxIcon.Question)
                     == DialogResult.Yes)
    {
      using (var contexto = new AgendaContext())
      {
        int id = Int32.Parse(listViewTelefonos.SelectedItems[0].SubItems[2]
            .Text);
        Telefono tel = (from t in contexto.Telefono
                        where t.Id == id
                        select t).Single();
 
        contexto.Telefono.DeleteObject(tel);
 
        contexto.SaveChanges();
      }
 
      CargarTelefonos();
      MessageBox.Show("Teléfono eliminado correctamente", "Eliminar telefono", 
         MessageBoxButtons.OK, MessageBoxIcon.Information);
    }
  }
}
```

Como supondrás el formulario para la gestión de los teléfonos es similar al de los contactos.

![Formulario de teléfonos](/uploads/posts/images/formulario_telefonos_EF.png)
 
El último método que voy a comentar será el de cargar los teléfonos de los contactos, este método se ejecutará cuando se lance el evento **SelectedIndexChange** del ListView de Contactos y su implementación es la siguiente:

``` csharp 
private void CargarTelefonos()
{
  listViewTelefonos.Items.Clear();
 
  if (listViewContactos.SelectedItems.Count > 0)
  {
    int contactoId = Int32.Parse(listViewContactos.SelectedItems[0].SubItems[2]
        .Text);
 
    using (var contexto = new AgendaContext())
    {
      Contacto c = (from cont in contexto.Contacto
                    where cont.Id == contactoId
                    select cont).Single();
 
      foreach (Telefono tel in c.Telefonos)
      {
        ListViewItem item = new ListViewItem(tel.Descripcion);
        item.SubItems.Add(tel.Numero.ToString());
        item.SubItems.Add(tel.Id.ToString());
        listViewTelefonos.Items.Add(item);
      }
    }
  }
}
```
 
Las acciones que realiza este método son: limpiar el listView de teléfonos y recuperar el contacto que ha sido seleccionado en el listView de contactos. Posteriormente recorre todos sus teléfonos y los añade en el listView de teléfonos.

Aquí finaliza esta pequeña introducción a Entity Framework, desde [aquí](/uploads/posts/samples/EntityFrameworkSample.rar) puedes descargar el ejemplo completo para ver todo su código. Si quieres más información puedes visitar está [página](http://msdn.microsoft.com/en-us/data/aa937723) donde encontrarás mucha documentación.