---
layout: post
comments: true
title: Consultas a bases de datos desde PHP con PDO
date: 2012-07-01 19:27:00
---

Si el desarrollo de tus aplicaciones lo haces con PHP usando como base de datos MySql y no utilizas ningún tipo de framework, seguramente las consultas a la base de datos las realizarás con el [API de mysql](http://php.net/manual/es/book.mysql.php). Un ejemplo del uso de este API es el siguiente:

{% highlight php linenos startinline=true %}
$con = mysql_connect('localhost', 'user', 'pass');

mysql_select_db('nombreBaseDatos');
$sql = 'SELECT * FROM tabla';

$res = mysql_query($sql);

while ($row = mysql_fetch_array($res))
  echo $row['titulo'];

mysql_free_result($res);
mysql_close($con);
{% endhighlight %}

Si este es tu caso, deberías saber que estás usando una API obsoleta y desaconsejada por el equipo de PHP. En su lugar deberías usar el [API de mysqli](http://www.php.net/manual/en/book.mysqli.php) o mejor aún [PDO](http://www.php.net/manual/en/book.pdo.php) (PHP Data Objects). Utilizando PDO podemos solventar muchas dificultades que surgen al utilizar la API de mysql. Un par de ventajas que se obtienen con PDO es que el proceso de escapado de los parámetros es sumamente sencillo y sin la necesidad de estar atentos a utilizar en todos los casos funciones para este cometido como *mysql_real_escape_string()*. Otra ventaja es que PDO es una API flexible y nos permite trabajar con cualquier tipo de base de datos y no estar restringidos a utilizar MySql.

<!--more-->

Veamos como podemos utilizar PDO en una aplicación para recuperar datos de una base de datos MySql y ver lo sencillo que es usar esta API. Lo primero que tenemos que hacer es realizar la conexión a la base de datos. La conexión la realizaremos con el [constructor de la clase](http://www.php.net/manual/en/pdo.construct.php) de la siguiente forma:

{% highlight php linenos startinline=true %}
$con = new PDO('mysql:host=localhost;dbname=nombreBaseDatos', 'user', 'pass');
{% endhighlight %}

Con la llamada anterior ya tenemos creada la conexión a la base de datos. Antes de continuar voy a explicar como tratar los posibles errores con PDO. Por defecto PDO viene configurado para no mostrar ningún error. Es decir que para saber si se ha producido un error, tendríamos que estar comprobando los métodos
[errorCode()](http://www.php.net/manual/en/pdo.errorcode.php) y [errorInfo()](http://www.php.net/manual/en/pdo.errorinfo.php). Para facilitarnos la tarea vamos a habilitar las excepciones. De esta forma cada vez que ocurra un error saltará una excepción que capturaremos y podremos tratar correctamente para mostrarle un mensaje al usuario. Para realizar esta tarea utilizaremos la función [setAttribute()](http://www.php.net/manual/en/pdostatement.setattribute.php) de la siguiente forma:

{% highlight php linenos startinline=true %}
$con = new PDO('mysql:host=localhost;dbname=nombreBaseDatos', 'user', 'pass');
$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
{% endhighlight %}

Los posibles valores que se le podría asignar a *ATTR_ERRMODE* son:

* **PDO::ERRMODE_SILENT** es el valor por defecto y como he mencionado antes no lanza ningún tipo de error ni excepción, es tarea del programador comprobar si ha ocurrido algún error después de cada operación con la base de datos.

* **PDO::ERRMODE_WARNING** genera un error E_WARNING de PHP si ocurre algún error. Este error es el mismo que se muestra usando la API de mysql mostrando por pantalla una descripción del error que ha ocurrido.

* **PDO::ERRMODE_EXCEPTION** es el que acabamos de explicar que genera y lanza una excepción si ocurre algún tipo de error.

Como acabamos de hacer que se lancen excepciones cuando se produzca algún error, el paso que tenemos que dar a continuación es capturarlas por si se producen, para ello realizamos lo siguiente:

{% highlight php linenos startinline=true %}
try {
  $con = new PDO('mysql:host=localhost;dbname=nombreBaseDatos', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
  echo 'Error conectando con la base de datos: ' . $e->getMessage();
}
{% endhighlight %}

Ahora que sabemos como conectarnos a la base de datos, vamos a crear una sentencia para poder recuperar datos. Para ejecutar sentencias podemos utilizar la llamada a [query()](http://www.php.net/manual/en/pdo.query.php) o bien la llamada a [prepare()](http://www.php.net/manual/en/pdo.prepare.php). Aunque tenemos disponibles las dos llamadas es mucho más seguro utilizar la llamada a **prepare()** ya que esta se encarga de escapar por nosotros los parámetros y nos asegura que no sufriremos problemas de SQL Injection. La función **query()** se suele utilizar cuando la sentencia que vamos a ejecutar no contiene parámetros que ha enviado el usuario. Veamos un ejemplo utilizando la función **query()**:

{% highlight php linenos startinline=true %}
try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $datos = $con->query('SELECT nombre FROM personal');
  foreach($datos as $row)
    echo $row[0] . '<br/>';
} catch(PDOException $e) {
  echo 'Error conectando con la base de datos: ' . $e->getMessage();
}
{% endhighlight %}

Si a pesar de las advertencias aun quieres ejecutar sentencias con **query()** pasándole parámetros de usuarios, la forma correcta de hacerlo sería escapando esos parámetros con la función [quote()](http://www.php.net/manual/en/pdo.quote.php) como se muestra a continuación:

{% highlight php linenos startinline=true %}
$ape = 'Hernandez';

try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $datos = $con->query(
    'SELECT nombre FROM personal WHERE apellidos like ' . $con->quote($ape)
  );
  foreach($datos as $row)
    echo $row[0] . '<br/>';
} catch(PDOException $e) {
  echo 'Error conectando con la base de datos: ' . $e->getMessage();
}
{% endhighlight %}

La forma de utilizar la función **prepare()** que es la más recomendada es la siguiente:

{% highlight php linenos startinline=true %}
try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $con->prepare('SELECT nombre FROM personal');
  $stmt->execute();

  while( $datos = $stmt->fetch() )
    echo $datos[0] . '<br/>';
} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}

Como se ve, es realmente simple ejecutar consultas. Simplemente tenemos que indicarle a la función **prepare()** la sentencia sql que queremos ejecutar. Esta función nos devolverá un [PDOStatement](http://www.php.net/manual/en/class.pdostatement.php) sobre el cual ejecutaremos la función [execute()](http://www.php.net/manual/en/pdostatement.execute.php) para que consulte los datos. A continuación simplemente los tenemos que recorrer con ayuda del método [fetch()](http://www.php.net/manual/en/pdostatement.fetch.php) para poder mostrar su valor.

Si necesitamos pasarle valores a la sentencia sql, utilizaríamos los parámetros. Los parámetros los indicamos en la misma sentencia sql y los podemos escribir de dos formas distintas. Mediante el signo **?** o mediante un nombre de variable precedido por el simbolo : **:nombreParam**. La segunda forma nos permite una identificación más fácil de los parámetros, pero cualquiera de las dos formas es correcta. Veamos un ejemplo:

{% highlight php linenos startinline=true %}
$ape = 'Hernandez';

try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $con->prepare(
    'SELECT nombre FROM personal WHERE apellidos like :apellidos'
  );
  $stmt->execute(array(':apellidos' => $ape ));

  while( $datos = $stmt->fetch() )
    echo $datos[0] . '<br />';
} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}

Como se ve hemos llamado al parámetro *:apellidos* y posteriormente en la llamada a la función **execute()** indicamos con un array asociativo el nombre del parámetro y su valor. Otra forma de indicar los parámetros es utilizando la función [bindParam](http://www.php.net/manual/en/pdostatement.bindparam.php).

{% highlight php linenos startinline=true %}
$ape = 'Hernandez';

try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $con->prepare(
    'SELECT nombre FROM personal WHERE apellidos like :apellidos'
  );
  $stmt->bindParam(':apellidos', $ape, PDO::PARAM_INT);
  $stmt->execute();

  while( $datos = $stmt->fetch() )
    echo $datos[0] . '<br />';
} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}

A la función **bindParam()** le pasamos el nombre del parámetro, su valor y finalmente el tipo que es. Los tipos de parámetros que le podemos pasar los podemos ver en las [constantes predefinidas de PDO](http://www.php.net/manual/en/pdo.constants.php) y son:

* PDO::PARAM_BOOL
* PDO::PARAM_NULL
* PDO::PARAM_INT
* PDO::PARAM_STR
* PDO::PARAM_LOB


Al igual que las sentencias select, podemos utilizar las funciones **query()** y **prepare()** para ejecutar inserts, updates y deletes. La forma de hacerlo es igual que lo que hemos estado viendo hasta ahora:

Ejemplo de insert:

{% highlight php linenos startinline=true %}
$nom = 'Jose';
$ape = 'Hernandez';

try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $con->prepare(
    'INSERT INTO personal (nombre, apellidos) VALUES (:nombre, :apellidos)'
  );
  $rows = $stmt->execute(array(':nombre'   => $nom, ':apellidos' => $ape));

  if( $rows == 1 )
    echo 'Inserción correcta';
} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}

Ejemplo de update:

{% highlight php linenos startinline=true %}
$nom = 'Jose';
$ape = 'Hernandez';

try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $con->prepare(
    'UPDATE personal SET apellidos = :apellidos WHERE nombre = :nombre'
  );
  $rows = $stmt->execute( array( ':nombre'   => $nom,
                                    ':apellidos' => $ape));
  if( $rows > 0 )
    echo 'Actualización correcta';
} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}

Ejemplo de delete:

{% highlight php linenos startinline=true %}
$ape = 'Hernandez';

try
{
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt = $con->prepare('DELETE FROM personal WHERE apellidos = :apellidos');
  $rows = $stmt->execute( array( ':apellidos' => $ape));

  if( $rows > 0 )
    echo 'Borrado correcto';
} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}


Para acabar con esta entrada sobre PDO vamos a ver otra de las funcionalidades que nos aporta y que puede ser muy útil. PDO nos permite realizar consultas y mapear los resultados en objetos de nuestro modelo. Para ello primero tenemos que crearnos una clase con nuestro modelo de datos.

{% highlight php linenos startinline=true %}
class Usuario  {
  private $nombre;
  private $apellidos;

  public function nombreApellidos() {
    return $this->nombre . ' ' . $this->apellidos;
  }
}
{% endhighlight %}

Hay que tener en cuenta que para que funcione correctamente, el nombre de los atributos en nuestra clase tienen que ser iguales que los que tienen las columnas en nuestra tabla de la base de datos. Con esto claro vamos a realizar la consulta.

{% highlight php linenos startinline=true %}
try {
  $con = new PDO('mysql:host=localhost;dbname=personal', 'user', 'pass');
  $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

  $stmt= $con->prepare('SELECT nombre, apellidos FROM personal');
  $stmt->execute();

  $stmt->setFetchMode(PDO::FETCH_CLASS, 'Usuario');

  while($usuario = $stmt->fetch())
    echo $usuario->nombreApellidos() . '<br />';

} catch(PDOException $e) {
  echo 'Error: ' . $e->getMessage();
}
{% endhighlight %}

La novedad que podemos ver en este script es la llamada al método [setFetchMode()](http://www.php.net/manual/es/pdostatement.setfetchmode.php) pasándole como primer argumento la constante PDO::FETCH_CLASS que le indica que haga un mapeado en la clase que le indicamos como segundo argumento, en este caso la clase Usuario que hemos creado anteriormente. Después al recorrer los elementos con *fetch* los resultados en vez de en un vector los obtendremos en el objeto indicado.

Después de todo esto solo me queda decir que si eres de los que todavía sigues usando la antigua API de mysql este es un buen momento para empezar a cambiar y a usar una nueva API más moderna y con mejores prestaciones.
