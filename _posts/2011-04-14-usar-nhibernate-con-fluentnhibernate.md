---
layout: post
comments: false
title: Usar NHibernate con FluentNHibernate
---

[NHibernate](http://nhforge.org/Default.aspx) es una herramienta para mapear tablas relacionales de una base de datos en objetos ([ORM](http://es.wikipedia.org/wiki/ORM)) cuando trabajamos con aplicaciones .NET. Utilizar este tipo de herramientas en nuestras aplicaciones es muy recomendable porque nos ayuda a tener las características propias de la orientación a objetos para trabajar con bases de datos, además de permitirnos cambiar de gestor de base de datos sin tener que realizar apenas cambios en nuestra aplicación. Aunque .NET nos proporciona [Entity Framework](http://msdn.microsoft.com/en-us/library/aa697427(v=vs.80).aspx) como herramienta ORM, este no tiene soporte para todo tipo de base de datos, como por ejemplo Oracle, así que si queremos usar un ORM podemos optar por NHibernate.


Una de las principales dificultades y que más intimidan a la hora de ponerse a trabajar con NHibernate es crear su fichero de configuración y los ficheros para mapear cada tabla en un objeto. Para hacer esta tarea menos costosa vamos a utilizar [FluentNHibernate](http://fluentnhibernate.org/) que es una librería que se encarga de llevar a cabo todo el trabajo que tendríamos que hacer a mano para conseguir mapear las tablas en objetos. A continuación vamos a ver un ejemplo de como utilizar estas dos herramientas.

<!--more-->

Para comenzar vamos a crear un proyecto .NET, tanto NHibernate como FluentNHibernate se puede usar para el desarrollo de aplicaciones web, como para aplicaciones de escritorio. Para nuestro ejemplo vamos a crear una aplicación web, así que abrimos Visual Studio y creamos una nueva <em>aplicación web ASP.NET</em> que llamaremos **EjemploNHibernate**. A continuación vamos a [descargar FluentNHibernate](http://fluentnhibernate.org/downloads). La versión actual es la 1.2 que funciona con NHibernate 3.1. Descomprimimos el fichero descargado y volvemos a Visual Studio, donde haremos clic derecho encima del proyecto y **añadiremos una referencia** nos movemos a la pestaña de **Examinar**, buscamos la carpeta donde hemos descomprimido FluentNHibernate y añadimos las siguientes dll:

* Castle.Core.dll
* FluentNHibernate.dll
* NHibernate.ByteCode.Castle.dll
* NHibernate.dll

La base de datos con la que trabajaremos tendrá la siguiente estructura:

![Estructura Base Datos](/uploads/posts/images/estructura-bd-nhibernate.png)

En Visual Studio hacemos clic derecho encima del proyecto y añadimos una nueva carpeta que llamaremos **Modelo**. Dentro de esta carpeta crearemos dos más, una de ellas la llamaremos **Mappings** y la otra **Entities**. Ahora nos ponemos encima de la carpeta **Modelo** y añadimos una nueva clase que llamaremos **SessionNHibernate**. Esta clase será la encargada de abrirnos una sesión con la base de datos para poder consultar, insertar, editar y borrar los datos. Su contenido es el siguiente:


{% highlight csharp linenos %}
using System;
using NHibernate;
using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;

namespace EjemploNHibernate.Modelo
{
  public class SessionNHibernate
  {
    private static ISessionFactory sessionFactory = null;
    private static ISession session = null;

    private static ISessionFactory SessionFactory
    {
      get
      {
        if (sessionFactory == null)
          sessionFactory = CreateSessionFactory();

        return sessionFactory;
      }
    }

    public static ISession Session
    {
      get { return session; }
    }


    public static ISession OpenSession()
    {
      session = SessionFactory.OpenSession();

      return session;
    }

    public static void CloseSession()
    {
      session.Close();
    }



    private static ISessionFactory CreateSessionFactory()
    {
      try
      {
        string connection = "Data Source=(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=
                     (PROTOCOL=TCP)(HOST=127.0.0.1)(PORT=1521)))(CONNECT_DATA=
                     (SERVER=DEDICATED)(SERVICE_NAME=XE)));User Id=usuario;
                      Password=password;";

        var db = OracleClientConfiguration.Oracle10.ConnectionString(
            connection);

        return Fluently.Configure().Database(db)
                     .Mappings(m => m.FluentMappings.AddFromAssemblyOf
                      <SessionNHibernate>()).BuildSessionFactory();
      }
      catch
      { 
      }

      return null;
    }
  }
}
{% endhighlight %}

Incluimos tres directivas using para poder utilizar tanto la librería NHibernate como FluentNHibernate, posteriormente creamos la clase que contendrá dos atributos estáticos. Uno de ellos será del tipo **ISessionFactory** y será el encargado de establecer la conexión con la base de datos. El otro atributo será de tipo **ISession** y se encargará de realizar las consultas contra la base de datos. Los métodos que usaremos serán **OpenSession** y **CloseSession** que serán los encargados de abrirnos una sesión para que podamos trabajar contra la base de datos. Otro método que también tenemos que tener en cuenta es **CreateSessionFactory** ya que es en este método donde le indicamos la cadena de conexión que tiene que usar para realizar la conexión.


Ahora crearemos las clases que usaremos para trabajar con ellas como si fueran la base de datos. Estas clases tendrán una propiedad virtual por cada campo de la base de datos que vayamos a mapear y le podremos poner los métodos que nos interesen. De momento vamos a crear la estructura básica de cada objeto y posteriormente iremos añadiéndole nuevos métodos conforme los necesitemos. Vamos a la carpeta **Entities** y añadimos una nueva clase que llamaremos **Empresa**:


{% highlight csharp linenos %}
using System.Collections.Generic;

using NHibernate;
using NHibernate.Criterion;

namespace EjemploNHibernate.Modelo.Entities
{
  public class Empresa
  {
    public virtual long IdEmpresa { get; private set; }
    public virtual string Nombre { get; set; }
    public virtual string CifNif { get; set; }
    public virtual string Telefono { get; set; }
    public virtual string Fax { get; set; }

    public virtual Municipio IdMunicipio { get; set; }
    public virtual IList<Establecimiento> Establecimientos { get; set; }

    public Empresa()
    {
      Establecimientos = new List<Establecimiento>();
    }
  }
}
{% endhighlight %}

Creamos otra nueva clase dentro de la misma carpeta llamada **Municipio**:

{% highlight csharp linenos %}
using System.Collections.Generic;

using NHibernate;
using NHibernate.Criterion;

namespace EjemploNHibernate.Modelo.Entities
{
  public class Municipio
  {
    public virtual long IdMunicipio { get; private set; }
    public virtual string Nombre { get; set; }

    public Municipio()
    {
    }
  }
}
{% endhighlight %}

Volvemos a hacer la misma operación y añadimos la clase **Establecimiento**:

{% highlight csharp linenos %}
using System.Collections.Generic;
using System.ComponentModel;
using NHibernate;
using NHibernate.Criterion;

namespace EjemploNHibernate.Modelo.Entities
{
  public class Establecimiento
  {
    public virtual long IdEstablecimiento { get; private set; }
    public virtual string Nombre { get; set; }
    public virtual Empresa Empresa { get; set; }
    public virtual string Direccion { get; set; }
    public virtual Municipio Municipio { get; set; }
    public virtual string Telefono { get; set; }
    public virtual string Fax { get; set; }

    public Establecimiento()
    {
    }
  }
}
{% endhighlight %}

Una vez que tenemos estas clases, ahora crearemos los mappings que usará FluentNHibernate para realizar el mapeo automáticamente. También tendremos que crear una clase para cada una de las tablas, así que vamos a la carpeta **Mappings** y agregamos una nueva clase que llamaremos **EmpresaMap** con el siguiente código:

{% highlight csharp linenos %}
using FluentNHibernate.Mapping;

using EjemploNHibernate.Modelo.Entities;

namespace EjemploNHibernate.Modelo.Mappings
{
  public class EmpresaMap : ClassMap<Empresa>
  {
    public EmpresaMap()
    {
      Table("EMPRESAS");
      Id(x => x.IdEmpresa);
      Map(x => x.Nombre);
      Map(x => x.CifNif);
      Map(x => x.Telefono);
      Map(x => x.Fax);

      References(x => x.IdMunicipio).Column("IDMUNICIPIO");

      HasMany<Establecimiento>(x => x.Establecimientos).KeyColumn("IDEMPRESA");
    }
  }
}
{% endhighlight %}

Esta clase heredará de la clase ClassMap indicándole como plantilla la clase de la entidad que vamos a mapear. En su constructor lo primero que hacemos es indicar con el método *Table* el nombre de la tabla. Si no llamamos a este método, por defecto toma el nombre de la tabla en la base de datos igual que el de la clase que estamos mapeando, en este caso empresa. Pero como en nuestra base de datos la tabla se llama empresas llamamos a este método para indicarlo. Seguidamente llamamos al método *Id* pasándole como argumento la propiedad que en la entidad equivale al id de la tabla. A continuación para el resto de campos utilizamos el método *Map* a excepción de la clave ajena que tenemos, la cual la pasaremos como parámetro al método *References*. El método *Column* que vemos, se encarga de indicar como se llama la columna en la base de datos, al igual que ocurre con el nombre de la tabla por defecto se toma el mismo nombre que la propiedad que estemos mapeando, pero si le hemos cambiado el nombre, con el método *Column* podemos indicar como se llama la columna en la base de datos. El último método que vemos es *HasMany* que indica que la propiedad Establecimientos tiene una relación a muchos con Establecimiento. Además mediante el método *KeyColumn* le indicamos cual es la columna que contiene la clave ajena en establecimiento.


Volvemos a añadir una nueva clase en la carpeta **Mappings** llamada **MunicipioMap**:


{% highlight csharp linenos %}
using FluentNHibernate.Mapping;

using EjemploNHibernate.Modelo.Entities;

namespace EjemploNHibernate.Modelo.Mappings
{
  public class MunicipioMap : ClassMap<Municipio>
  {
    public MunicipioMap()
    {
      Table("MUNICIPIOS");
      Id(x => x.IdMunicipio);
      Map(x => x.Nombre);
    }
  }
}
{% endhighlight %}

Seguimos con la clase que nos falta **EstablecimientoMap**:

{% highlight csharp linenos %}
using FluentNHibernate.Mapping;
using EjemploNHibernate.Modelo.Entities;

namespace EjemploNHibernate.Modelo.Mappings
{
  public class EstablecimientoMap : ClassMap<Establecimiento>
  {
    public EstablecimientoMap()
    {
      Table("ESTABLECIMIENTOS");
      Id(x => x.IdEstablecimiento).GeneratedBy
        .Sequence("SEQ_ESTABLECIMIENTOS");
      Map(x => x.Nombre);
      Map(x => x.Direccion);
      Map(x => x.Telefono);
      Map(x => x.Fax);

      References(x => x.Empresa).Column("IDEMPRESA");
      References(x => x.Municipio).Column("IDMUNICIPIO");
    }
  }
}
{% endhighlight %}

En este último elemento que mapeamos utilizamos una nueva propiedad llamada *GeneratedBy* con esto le estamos indicando a NHibernate que cuando genere un nuevo establecimiento para el id tiene que utilizar la secuencia indicada. Esto lo tendríamos que haber realizado también para el resto de elementos, pero como en este ejemplo solo permitiremos insertar establecimientos me he ahorrado esos pasos.

Ahora ya tenemos todo configurado y podemos comenzar a trabajar. Voy a ir directo al grano y no voy a explicar como he realizado cada pantalla, así no será tan pesado el tutorial. Si queréis ver el código de las pantalla podéis descargar el proyecto y verlo. Voy a crear tres WebForms, uno para listar los establecimientos, otro para insertar nuevos establecimientos y otro para editarlos.

Comencemos por el WebForm de listar las empresas, su resultado final será como muestra esta imagen:

![Listar Establecimientos](/uploads/posts/images/listar-nhibernate.jpg)

Como vemos es una pantalla simple, tenemos una lista de empresas y debajo de cada empresa tenemos el listado de los establecimientos que pertenecen a esa empresa. Para realizar esto vamos a ir a la clase **Empresa** y vamos a crearnos un método estático que nos devuelva todas las empresas.

{% highlight csharp linenos %}
//Modelo/Entities/Empresa.cs
public static List<Empresa> GetAllEmpresas()
{
  return (SessionNHibernate.Session.CreateCriteria<Empresa>().AddOrder(
      Order.Asc("Nombre")).List<Empresa>() as List<Empresa>);
}
{% endhighlight %}

Vamos a explicar con detalle lo que hemos hecho en este método. Comenzamos llamando a la clase *SessionNHibernate* que nos hemos creado anteriormente y obtenemos el atributo *ISession* mediante la propiedad que creamos. A continuación llamamos al método *CreateCriteria<Empresa>* que pertenece a NHibernate y nos va a permitir realizar un criterio para buscar en la base de datos. A este método tenemos que indicarle la entidad sobre la que vamos a crear el criterio, en este caso Empresa. Cuando ya tenemos el criterio le indicamos que nos ordene el resultado por la columna *Nombre* llamando al método *AddOrder* sobre el objeto criteria. Por último le decimos que queremos obtener un *List<Empresa>*. Con todo esto, el resultado de la llamada a este método es una lista con todas las empresas que hay en la base de datos ordenadas por su nombre.

Ahora que ya sabemos como obtenemos todas las empresas vamos al fichero Default.aspx.cs y modificamos su método *Page_Load* para dejarlo así:

{% highlight csharp linenos %}
//... código creado automáticamente

using NHibernate;

using EjemploNHibernate.Modelo;
using EjemploNHibernate.Modelo.Entities;

//... código creado automáticamente

protected void Page_Load(object sender, EventArgs e)
{
  SessionNHibernate.OpenSession();

  foreach (Empresa emp in Empresa.GetAllEmpresas())
  {
    Label lEmpresa = new Label();
    lEmpresa.Text = emp.Nombre;

    Panel panelEstablecimientos = new Panel();
    panelEstablecimientos.Style.Add("margin", "0 0 10px 20px");

    foreach (Establecimiento est in emp.Establecimientos)
    {
      HyperLink hlEditar = new HyperLink();
      hlEditar.Text = "Editar";
      hlEditar.NavigateUrl = "Editar.aspx?est=" + est.IdEstablecimiento;

      HyperLink hlEliminar = new HyperLink();
      hlEliminar.Text = "Borrar";
      hlEliminar.NavigateUrl = "Eliminar.aspx?est=" + est.IdEstablecimiento;
      hlEliminar.Attributes.Add("onclick", "return confirm('¿Quiere eliminar 
          este establecimiento?');");
                    
      Label lNombre = new Label();
      lNombre.Text = est.Nombre;

      Literal lEspacio = new Literal();
      lEspacio.Text = "  ";
      Literal lEspacio2 = new Literal();
      lEspacio2.Text = "  ";
      Literal lSaltoLinea = new Literal();
      lSaltoLinea.Text = "<br />";

      panelEstablecimientos.Controls.Add(lNombre);
      panelEstablecimientos.Controls.Add(lEspacio);
      panelEstablecimientos.Controls.Add(hlEditar);
      panelEstablecimientos.Controls.Add(lEspacio2);
      panelEstablecimientos.Controls.Add(hlEliminar);
      panelEstablecimientos.Controls.Add(lSaltoLinea);
    }

    PanelEmpresas.Controls.Add(lEmpresa);
    PanelEmpresas.Controls.Add(panelEstablecimientos);
  }

  SessionNHibernate.CloseSession();
}
{% endhighlight %}

En lo primero que hay que fijarse es en los using incluidos para poder hacer uso tanto de las entidades que hemos creado anteriormente como de NHibernate. Después en el método lo primero que hacemos es llamar a *SessionNHibernate.OpenSession*, llamamos a la clase que nos creamos y abrimos la sesión para poder consultar los datos. A continuación con un foreach recorremos todas las empresas que nos devuelve el método *GetAllEmpresas* que creamos antes. Las siguientes líneas son la creación de controles dinámicos y rellenarlos con las propiedades del objeto empresa que estamos tratando en cada iteración. Como vemos mediante el atributo **Establecimientos** del objeto **Empresa** obtenemos todos los establecimientos para esa empresa y los podemos recorrer sin ninguna dificultad. Para finalizar añadimos los controles en los paneles creados y cerramos la sesión llamando al método *SessionNHibernate.CloseSession()*

Veamos ahora la pantalla para insertar un nuevo establecimiento:

![Insertar Establecimiento](/uploads/posts/images/insertar-nhibernate.jpg)

Como se ve, es un formulario simple que solicita los datos para crear un nuevo establecimiento. Lo primero que necesitamos para insertar un nuevo establecimiento es poder seleccionar a que empresa pertenece y en que municipio se encuentra. El método que obtiene todas las empresas ya lo hemos creado anteriormente, así que ahora vamos a crear un método que nos devuelva todos los municipios disponibles. Para ello vamos a la clase **Municipio** y creamos el método *GetAllMunicipios*.

{% highlight csharp linenos %}
//Modelo/Entities/Municipio.cs
public static List<Municipio> GetAllMunicipios()
{
  return (SessionNHibernate.Session.CreateCriteria<Municipio>().AddOrder(
      Order.Asc("Nombre")).List<Municipio>() as List<Municipio>);
}
{% endhighlight %}

Una vez que tenemos este método podemos cargar los DropDownList de la pantalla de insertar establecimientos desde el método *Page_Load*.

{% highlight csharp linenos %}
//Default.aspx.cs

//... código creado automáticamente

using NHibernate;

using EjemploNHibernate.Modelo;
using EjemploNHibernate.Modelo.Entities;

//... código creado automáticamente
protected void Page_Load(object sender, EventArgs e)
{
  ISession s = SessionNHibernate.OpenSession();

  DDEmpresa.Items.Add(new ListItem("Seleccione una empresa", "-1"));
  foreach (Empresa emp in Empresa.GetAllEmpresas())
    DDEmpresa.Items.Add(new ListItem(emp.Nombre, emp.IdEmpresa.ToString()));

  DDMunicipio.Items.Add(new ListItem("Seleccione un municipio", "-1"));
  foreach (Municipio m in Municipio.GetAllMunicipios())
    DDMunicipio.Items.Add(new ListItem(m.Nombre, m.IdMunicipio.ToString()));

  SessionNHibernate.CloseSession();
}
{% endhighlight %}

Su funcionalidad es sencilla, abre la sesión y con un foreach recorre todas las empresas y las va añadiendo al DropDownList de empresas, posteriormente realiza la misma función con los municipios. Antes de ponernos a ver que realiza el botón *Aceptar* para guardar el establecimiento en la base de datos vamos a crear dos métodos nuevos en las clases **Empresa** y **Municipio** que usaremos a continuación.

{% highlight csharp linenos %}
//Modelo/Entities/Empresa.cs

public static Empresa Get(long id)
{
  return SessionNHibernate.Session.Get<Empresa>(id);
}
{% endhighlight %}

El método *Get* de la clase **Empresa** simplemente recibe el id de una empresa y luego utilizando el atributo *Session* de la clase **SessionNHibernate** que creamos anteriormente, llama a su método *Get* pasándole como plantilla la entidad actual, en este caso empresa. Automáticamente se buscará en la base de datos la empresa que contenga ese id y se devolverá.

{% highlight csharp linenos %}
//Modelo/Entitites/Municipio.cs

public static Municipio Get(long id)
{
  return SessionNHibernate.Session.Get<Municipio>(id);
}
{% endhighlight %}

Para los municipios tenemos un método igual que el anterior que usaremos de la misma manera. Ahora podemos ver el método que se ejecuta cuando pulsamos en el botón *Aceptar* en la pantalla de insertar establecimiento.

{% highlight csharp linenos %}
//Default.aspx.cs

protected void ButtonAceptar_Click(object sender, EventArgs e)
{
  if (DDEmpresa.SelectedValue != "-1" || DDMunicipio.SelectedValue != "-1")
  {
    ISession s = SessionNHibernate.OpenSession();
    Establecimiento est = new Establecimiento();

    long idEmpresa, idMunicipio;

    if (long.TryParse(DDEmpresa.SelectedValue, out idEmpresa) && 
             long.TryParse(DDMunicipio.SelectedValue, out idMunicipio))
    {
      est.Direccion = TBDireccion.Text;
      est.Empresa = Empresa.Get(idEmpresa);
      est.Fax = TBFax.Text;
      est.Municipio = Municipio.Get(idMunicipio);
      est.Telefono = TBTelefono.Text;
      est.Nombre = TBNombre.Text;

      try
      {
        s.SaveOrUpdate(est);
        s.Flush();

        LabelError.Text = "Establecimiento guardado con éxito";
        LabelError.ForeColor = System.Drawing.Color.Green;
        LabelError.Visible = true;

        LimpiarCampos();
      }
      catch (Exception ex)
      {
        LabelError.Text = ex.Message;
        LabelError.ForeColor = System.Drawing.Color.Red;
        LabelError.Visible = true;
      }
      finally
      {
        SessionNHibernate.CloseSession();
      }
    }
    else
    {
      LabelError.Text = "Empresa o municipio seleccionado no valido";
      LabelError.Visible = true;
    }
  }
  else
  {
    LabelError.Text = "Tiene que seleccionar una empresa y un municipio";
    LabelError.Visible = true;
  }
}
{% endhighlight %}

Lo primero que comprobamos es que se haya seleccionado un campo tanto en el DropDownList de empresas como en el de municipios. Posteriormente abrimos la sesión llamando al método *SessionNHibernate.OpenSession* y nos guardamos el objeto que devuelve para usarlo más tarde. Nos creamos un nuevo objeto **Establecimiento** y rellenamos sus datos con la información que se ha insertado en los TextBox así como por los métodos *Get* de las clases **Empresa** y **Municipio**. Seguidamente llamamos al método *s.SaveOrUpdate* utilizando el valor de la sesión que nos guardamos antes y hacemos que este nuevo establecimiento quede almacenado en memoria. Para guardar el establecimiento de forma permanente, llamamos al método *s.Flush* y se añadirá la tupla correspondiente en la base de datos. El resto del código sirve para mostrar los mensajes de información al usuario tanto en el caso de éxito como en el de error a la hora de guardar y para cerrar la sesión.

Una vez que hemos visto como guardar un nuevo elemento en la base de datos vamos a ver como se modifica uno existente. Para ello, si recuerdas cuando creamos la página de listar las empresas, creamos un HyperLink por cada establecimiento que redireccionaba a una página llamada Editar.aspx y enviaba un parámetro mediante get con el id del establecimiento. Gracias a este parámetro podemos recuperar todos los datos del establecimiento y mostrarlos en un formulario para que el usuario los pueda editar y actualizar. Para comenzar veamos como quedará nuestra pantalla.

![Editar Establecimiento](/uploads/posts/images/editar-nhibernate.jpg)

Es un formulario igual al de insertar, pero este consta de un control HiddenField para almacenar el id del establecimiento que estamos editando. El código desde el cual recuperamos los datos del establecimiento se ejecuta en el método *Page_Load* de la página editar y es el siguiente:

{% highlight csharp linenos %}
//Editar.aspx.cs

protected void Page_Load(object sender, EventArgs e)
{
  if (Request.QueryString.Count == 0 || Request.QueryString["est"] == null)
    Response.Redirect("Default.aspx");

  long idEstablecimiento;

  if( !long.TryParse(Request.QueryString["est"], out idEstablecimiento) )
    Response.Redirect("Default.aspx");


  ISession s = SessionNHibernate.OpenSession();

  Establecimiento est = Establecimiento.Get(idEstablecimiento);

  DDEmpresa.Items.Add(new ListItem("Seleccione una empresa", "-1"));
  foreach (Empresa emp in Empresa.GetAllEmpresas())
    DDEmpresa.Items.Add(new ListItem(emp.Nombre, emp.IdEmpresa.ToString()));

  DDMunicipio.Items.Add(new ListItem("Seleccione un municipio", "-1"));
  foreach (Municipio m in Municipio.GetAllMunicipios())
    DDMunicipio.Items.Add(new ListItem(m.Nombre, m.IdMunicipio.ToString()));

  DDEmpresa.SelectedValue = est.Empresa.IdEmpresa.ToString();

  DDMunicipio.SelectedValue = est.Municipio.IdMunicipio.ToString();

  TBDireccion.Text = est.Direccion;
  TBFax.Text = est.Fax;
  TBTelefono.Text = est.Telefono;
  TBNombre.Text = est.Nombre;

  HFEstablecimiento.Value = idEstablecimiento.ToString();

  SessionNHibernate.CloseSession();
}
{% endhighlight %}

Lo primero que hacemos es mirar que se ha recibido por get un id de un establecimiento, si no se ha recibido o es otra cosa que no se puede parsear a long, se redirecciona de nuevo a la página de listar. Si hasta aquí todo es correcto, abrimos una sesión y recuperamos el establecimiento utilizando el método *Get* de la clase **Establecimiento** pasándole el id. Posteriormente rellenamos los DropDownList de empresas y municipios con todas las opciones disponibles, además, seleccionamos los valores actuales para el establecimiento. Establecemos en los TextBox el texto de cada propiedad y guardamos el id del establecimiento en el campo hidden. Para finalizar cerramos la sesión.

Nos queda ver las acciones que realizan los botones Cancelar y Actualizar. El botón Cancelar simplemente redirige a la pantalla de listado de empresas, mientras que el botón actualizar es el que se encarga de almacenar los cambios en la base de datos. El código para ambos botones es el siguiente:

{% highlight csharp linenos %}
//Editar.aspx.cs

protected void ButtonActualizar_Click(object sender, EventArgs e)
{
  if (DDEmpresa.SelectedValue != "-1" || DDMunicipio.SelectedValue != "-1")
  {
    long idEstablecimiento;

    if (long.TryParse(HFEstablecimiento.Value, out idEstablecimiento))
    {              
      long idMunicipio, idEmpresa;

      if (!long.TryParse(DDMunicipio.SelectedValue, out idMunicipio) && 
            !long.TryParse(DDEmpresa.SelectedValue, out idEmpresa))
      {
        ISession s = SessionNHibernate.OpenSession();
        Establecimiento est = Establecimiento.Get(idEstablecimiento);

        try
        {
          est.Nombre = TBNombre.Text;
          est.Direccion = TBDireccion.Text;
          est.Municipio = Municipio.Get(idMunicipio);
          est.Empresa = Empresa.Get(idEmpresa);
          est.Fax = TBFax.Text;
          est.Telefono = TBTelefono.Text;

          s.SaveOrUpdate(est);
          s.Flush();

          LabelError.Text = "Establecimiento guardado con éxito";
          LabelError.ForeColor = System.Drawing.Color.Green;
          LabelError.Visible = true;

        }
        catch (Exception ex)
        {
          LabelError.Text = ex.Message;
          LabelError.ForeColor = System.Drawing.Color.Red;
          LabelError.Visible = true;
        }
        finally
        {
          SessionNHibernate.CloseSession();
        }
      }
      else
      {
        LabelError.Text = "No se encuentra la empresa o el municipio " +
            "seleccionado";
        LabelError.Visible = true;
      }
    }
    else
    {
      LabelError.Text = "No se encuentra la empresa seleccionada";
      LabelError.Visible = true;
    }
  }
  else
  {
    LabelError.Text = "Tiene que seleccionar una empresa y un municipio";
    LabelError.Visible = true;
  }
}

protected void ButtonCancelar_Click(object sender, EventArgs e)
{
  Response.Redirect("Default.aspx");
}
{% endhighlight %}

Como se puede ver el código es idéntico al de insertar un nuevo establecimiento, la única diferencia es que en vez de crear un objeto **Establecimiento** nuevo, lo recuperamos de la base de datos con el id que tenemos en el campo hidden y después actualizamos todos sus datos. El método *SaveOrUpdate*, que hemos llamado tanto en la inserción como ahora en la edición, es el que se encarga de saber si es un objeto nuevo o estamos modificando uno ya existente para realizar el insert o el update contra la base de datos según corresponda. Al igual que antes el método *Flush* es importante que lo llamemos para hacer persistente los cambios en la base de datos.

Para finalizar nos queda ver como eliminar un establecimiento. En la pantalla de listados también creamos un enlace para cada establecimiento hacia Eliminar.aspx pasándole el id del establecimiento. Esta pantalla simplemente borrara el establecimiento indicado y muestra un mensaje con el resultado permitiendo volver de nuevo al listado de empresas. El código donde realizamos el borrado está en el método *Page_Load* y es el siguiente:

{% highlight csharp linenos %}
//Eliminar.aspx.cs

protected void Page_Load(object sender, EventArgs e)
{
  if (Request.QueryString.Count == 0 || Request.QueryString["est"] == null)
    Response.Redirect("Default.aspx");

  long idEstablecimiento;

  if (!long.TryParse(Request.QueryString["est"], out idEstablecimiento))
    Response.Redirect("Default.aspx");

  ISession s = SessionNHibernate.OpenSession();

  Establecimiento est = Establecimiento.Get(idEstablecimiento);

  try
  {
    s.Delete(est);
    s.Flush();

    LMensaje.Text = "Establecimiento borrado correctamente";
    LMensaje.ForeColor = System.Drawing.Color.Green;
  }
  catch (Exception ex)
  {
    LMensaje.Text = ex.Message;
    LMensaje.ForeColor = System.Drawing.Color.Red;
  }
  finally
  {
    SessionNHibernate.CloseSession();
  }

}
{% endhighlight %}

Como se ve el código es el mismo que usamos para editar con la única diferencia que esta vez usamos el método *Delete* para eliminar el objeto de la base de datos.

Después de seguir todos estos pasos has podido comprobar que utilizar NHibernate con la ayuda de FluentNHibernate es muy sencillo, ahora lo puedes aplicar en tus proyectos y sacarle todo el partido a la utilización de un ORM. Si quieres descargar el proyecto complete que he seguido durante el ejemplo puedes descargarlo desde [aquí](/uploads/posts/samples/EjemploNHibernate.rar).