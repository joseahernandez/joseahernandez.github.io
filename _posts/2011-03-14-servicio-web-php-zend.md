---
layout: post
comments: false
title: Servicio Web en PHP con Zend
---

En una entrada anterior expliqué [como crear un servicio web con php](/2011/01/18/servicio-web-php.html). En esta ocasión voy a crear otro servicio web, pero esta vez vamos a crear el fichero [WSDL](http://es.wikipedia.org/wiki/WSDL) de descripción del servicio para que cualquiera pueda trabajar con él. Para realizar esto de una forma sencilla voy a utilizar el [Zend Framework](http://framework.zend.com/). El uso del Zend Framework es únicamente porque nos proporciona una forma sencilla de generar el archivo WSDL del servicio. De esta forma ahorramos mucho tiempo en crear este costoso fichero y nos libramos de posibles errores en su contenido.

Comenzaremos [descargando el Zend Framework](http://www.zend.com/community/downloads). Cuando la descarga finalice y descomprimamos el fichero, accedemos a la ruta *library/Zend/*, en ella copiamos la carpeta **Soap** y la pegamos en nuestro directorio de trabajo puesto que las clases que vamos a necesitar para el desarrollo del servicio están en esa carpeta y no necesitamos el Zend Framework al completo.

<!--more-->

Usaremos la misma base de datos que en el ejemplo antes mencionado, el script de creación y de datos lo puedes obtener desde [aquí](/uploads/posts/samples/bd_servicio_web.sql).


La clase que implementará los métodos que vamos a ofrecer como servicios web será la misma, pero en esta ocasión tendrá unos comentarios en los métodos disponibles:

``` php
<?php
class GestionAutomoviles
{
  /**
   * Metodo que obtiene todas las marcas de coches disponibles
   *
   * @return array
   */
  public function ObtenerMarcas()
  {
    $con = mysql_connect('localhost', 'root', '');
    mysql_query("SET CHARACTER SET utf8");
    mysql_query("SET NAMES utf8");

    $marcas = array();

    if( $con )
    {
      mysql_select_db('coches');

      $result = mysql_query('select id, marca from marcas');

      while( $row = mysql_fetch_array($result) )
        $marcas[$row['id']] = $row['marca'];

      mysql_free_result($result);
      mysql_close($con);
    }

    return $marcas;
  }

  /**
   * Metodo que obtiene todos los modelos de la marca indicada disponibles
   *
   * @param int $marca
   * @return array
   */
  public function ObtenerModelos($marca)
  {
    $marca = intVal($marca);
    $modelos = array();

    if( $marca !== 0 )
    {
      $con = mysql_connect('localhost', 'root', '');
      mysql_query("SET CHARACTER SET utf8");
      mysql_query("SET NAMES utf8");

      if( $con )
      {
        mysql_select_db('coches');

        $result = mysql_query('select id, modelo from modelos where marca = ' 
            . $marca );

        while( $row = mysql_fetch_array($result) )
          $modelos[$row['id']] = $row['modelo'];

        mysql_free_result($result);
        mysql_close($con);
      }
    }

    return $modelos;
  }
}
?>
```

Los comentarios que aparecen delante de los métodos, describen su funcionalidad y proporcionan información para que cualquier persona que quiera consumir el servicio pueda realizarlo sabiendo los parámetros que tiene que pasarle y el valor que devuelve.

Estos comentarios serán usados por Zend para generar el fichero WSDL así que tendremos que seguir la misma estructura que en el ejemplo. La primera linea describe que hace la función, después ponemos los parámetros que acepta el método precedidos por **@param**, cada parámetro irá en una linea distinta. Por último indicamos que dato devuelve poniendo al principio de la linea **@return**

Ahora crearemos el servicio, para ello creamos un nuevo archivo que llamaremos *servicio.php*, en él pondremos el siguiente código:

``` php
<?php
  include 'Soap/AutoDiscover.php';
  include 'Soap/Server.php';
  include 'GestionAutomoviles.class.php';

  if(isset($_GET['wsdl'])) 
  {
    $autodiscover = new Zend_Soap_AutoDiscover();
    $autodiscover->setClass('GestionAutomoviles');
    $autodiscover->handle();
  } 
  else 
  {
    $soap = new Zend_Soap_Server(
        "http://localhost/webservice/servicio.php?wsdl"
    );
    $soap->setClass('GestionAutomoviles');
    $soap->handle();
  }

?>
```

Al principio del fichero incluimos tanto la clase que hemos generado anteriormente como las clases **AutoDiscover** y **Server** de Zend para poder utilizarlos. Posteriormente miramos si tenemos el parámetro wsdl en la url de la solicitud. En caso afirmativo creamos un objeto de tipo **Zend_Soap_AutoDiscover** que es el que se encargará de generar la descripción del servicio en formato WSDL. Después le indicamos al objeto creado cual es la clase que contiene los métodos y por último llamamos al metodo **handle**.

Si no está el parámetro wsdl en la url lo que hacemos es crearnos un objeto **Zend_Soap_Server**, el parámetro que le pasamos es la url del propio fichero, pero con el parámetro wsdl ya que este método necesita la descripción del servicio para realizar su tarea. Seguidamente le indicamos cual es la clase que contiene los métodos con **setClass** y por último llamamos al método **handle**.

El código del cliente para consumir el servicio será este:

``` php
<?php
   include 'Soap/Client.php';
   $client = new Zend_Soap_Client(
    'http://localhost/webservice/servicio.php?wsdl'
   );

   $marcas = $client->ObtenerMarcas();
?>

   <h1>Listado de marcas y modelos disponibles</h1>

   <ul>
   <?php
      foreach($marcas as $key => $value )
      {
   ?>
         <li>
            <?php echo $value; ?>
            <ul>
            <?php
               $modelos = $client->ObtenerModelos($key);

               foreach($modelos as $m)
               {
            ?>
                  <li><?php echo $m; ?></li>
            <?php
               }
            ?>
            </ul>
         </li>
   <?php
      }
   ?>
   </ul>
```

Como vemos simplemente creando un objeto de tipo **Zend_Soap_Client** y pasandolo el fichero (url o ruta) WSDL tenemos el objeto con el cual podemos llamar a los métodos que implementa el servicio.