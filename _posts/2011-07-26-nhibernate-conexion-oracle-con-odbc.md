---
layout: post
comments: false
title: NHibernate conexión a Oracle con ODBC
---

El otro día tuve que realizar una conexión a una base de datos Oracle por ODBC usando NHibernate y FluentNHibernate. La verdad es que me costó bastante encontrar la forma de realizar la conexión y después de conseguirlo el resultado no fue muy satisfactorio. Las consultas, modificaciones, inserciones y borrados de los datos se realiza satisfactoriamente, pero los problemas llegan cuando hay que hacer transacciones, inserciones y reutilización de objetos que acabamos de insertar y todas estas operaciones algo más complejas.

Comenzamos viendo como realizar la conexión. Lo primero que hay que crearse es una clase para la configuración a la que llamaremos **OdbcConfiguration**.

<!--more-->

{% highlight csharp linenos %}
using NHibernate;
using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;

public class OdbcConfiguration : PersistenceConfiguration<OdbcConfiguration, 
     FluentNHibernate.Cfg.Db.OdbcConnectionStringBuilder>
{
  protected OdbcConfiguration()
  {
    Driver<NHibernate.Driver.OdbcDriver>();
  }

  public static OdbcConfiguration MyDialect
  {
    get
    {
      return new OdbcConfiguration().Dialect<NHibernate.Dialect
        .Oracle10gDialect>();
    }
  }
} 
{% endhighlight %}

La clase extiende de **PersistenceConfiguration**, una clase que pertenece a FluentNHibernate, le pasamos como argumentos el nombre de la clase que estamos creando y el tipo de cadena de conexión que vamos a usar. En este caso el nombre de la clase **OdbcConfiguration** y el tipo de cadena de conexión **OdbcConnectionStringBuilder**.

En el constructor llamamos al método **Driver** indicando el tipo de driver que vamos a utilizar para la conexión, en este caso **OdbcDriver**.

Lo siguiente que hacemos es crear una propiedad estática que nos devolverá la configuración. En este caso a la propiedad la he llamado **MyDialect** pero podía haber usado cualquier nombre. Ella únicamente contendrá un get que devolverá una nueva configuración que utilizará el dialecto de Oracle10g para realizar la conexión.

Una vez tenemos esta clase implementada, podemos implementar el método que nos creará la sesión para realizar nuestras operaciones con la base de datos.

{% highlight csharp linenos %}
private static ISessionFactory CreateSessionFactory(string connectionString)
{
  try
  {
    FluentConfiguration config = Fluently.Configure();
    
    config.Database(OdbcConfiguration.MyDialect.ConnectionString(
         connectionString).Driver<NHibernate.Driver.OdbcDriver>()
         .ShowSql());

    config.Mappings(m => m.FluentMappings
        .AddFromAssemblyOf<SessionNHibernate>());

    return config.BuildSessionFactory();
  }
  catch (Exception)
  {
  }

  return null;
}
{% endhighlight %}

Este método recibe la cadena de conexión y simplemente realiza la configuración para poder realizar la conexión correctamente. Como vemos en la línea 7 le indicamos en la configuración que la base de datos a utilizar, utiliza el dialecto de nuestra clase **OdbcConfiguration**. Simplemente con estos pasos conseguiremos realizar la conexión a Oracle mediante ODBC.

Como he comentado al principio, hay algunas cosas que no me gustas de utilizar ODBC. Una de ellas y la que más dolores de cabeza me han dado ha sido crear un objeto, relacionarlo con otro y posteriormente insertar ambos en la base de datos. Un ejemplo sencillo podría ser el siguiente:

{% highlight csharp linenos %}
using( ITransaction transaccion = session.BeginTransaction() )
{
  try
  {
    Persona p = new Persona();
    p.Nombre = "Paco";
    p.Apellidos = "Martinez Garcia";
    p.telefono = "043984328";

    session.SaveOrUpdate(p);

    Coche c = new Coche();
    c.Marca = "Seat"
    c.Modelo = "Leon";
    c.Matricula = "54454ZZZ";
    c.Propietario = p;
  
    session.SaveOrUpdate(c);

    session.Transaction.Commit();
  }
  catch(Exception)
  {
    session.Transaction.Rollback();
  }
{% endhighlight %}

Este código con el conector de Oracle funciona sin problemas, pero ODBC no es capaz de recuperar la clave primera de la inserción del objeto Persona para luego asignarla al objeto Coche, con lo que se produce un error.

La solución que yo le he dado a este problema ha sido después de almacenar el objeto, recuperar de la base de datos un objeto con sus atributos iguales que el que acabada de guardar y posteriormente asignarlo al otro objeto. En mi caso he tenido la suerte de que contenía un campo que debía ser único en la base de datos, pero en caso de no tener ese campo esta forma no hubiese servido ya que podríamos obtener inconsistencia en los datos si tuviéramos dos personas con los mismos datos. ¿Alguien conoce cuál sería la forma correcta de realizar esta operación con ODBC?