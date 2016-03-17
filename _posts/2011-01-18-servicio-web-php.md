---
layout: post
comments: false
title: Servicio Web en PHP
---

Un [servicio web](http://es.wikipedia.org/wiki/Servicio_web) es usado para intercambiar datos entre distintas aplicaciones. El punto fuerte de los servicios web es que los datos que se solicitan al servicio se pueden usar con cualquier lenguaje de programación y sobre cualquier plataforma, con lo cual nos ofrecen una gran libertad.

Una de las dificultades de crear estos servicios usando únicamente php es que no hay forma de generar automáticamente los ficheros [WSDL](http://es.wikipedia.org/wiki/WSDL). Estos ficheros son los encargados de describir el servicio con las funciones que contiene y los parámetros que utilizan para que de esta forma cualquier programador pueda hacer uso del servicio. Por lo tanto lo podemos crear a mano, lo cual es una tarea dificultosa, o no crearlo de forma que habría que conocer que funciones y que parámetros tiene el servicio para usarlo. En este ejemplo no vamos a usar ningún fichero WSDL, pero como conoceremos que es lo que contiene el servicio lo podremos utilizar perfectamente.

Para comenzar vamos a crear una base de datos en MySQL para realizar las pruebas. Esta base de datos contendrá una tabla llamada *marcas* y otra *modelos* en las que almacenaremos distintos datos de marcas y modelos de coches. De [aquí](/uploads/posts/samples/bd_servicio_web.sql) puedes descargar el script que he usado para el ejemplo.

<!--more-->

Una vez tenemos la base de datos lista, crearemos una clase que implementará los métodos que vamos a ofrecer como servicios web. Esta clase la guardaremos en un fichero llamado *GestionAutomoviles.class.php* y contendrá el siguiente código:

{% highlight php linenos %}
<?php
class GestionAutomoviles {
    public function ObtenerMarcas() {    
        $con = mysql_connect('localhost', 'root', '');
        mysql_query("SET CHARACTER SET utf8");
        mysql_query("SET NAMES utf8");
    
        $marcas = array();
        if( $con ) { 
            mysql_select_db('coches');
            $result = mysql_query('select id, marca from marcas');
      
            while( $row = mysql_fetch_array($result) )
                $marcas[$row['id']] = $row['marca'];
      
            mysql_free_result($result);
            mysql_close($con);
        }
        return $marcas;
    }
    
    public function ObtenerModelos($marca) {
        $marca = intVal($marca);
        $modelos = array();
        
        if( $marca !== 0 ) {
            $con = mysql_connect('localhost', 'root', '');
            mysql_query("SET CHARACTER SET utf8");
            mysql_query("SET NAMES utf8");
            if( $con ) {
                mysql_select_db('coches');
                $result = mysql_query('select id, modelo from modelos ' .
                    'where marca = ' . $marca );
                
                while( $row = mysql_fetch_array($result) ) 
                    $modelos[$row['id']] = $row['modelo'];
                
                mysql_free_result($result);
                mysql_close($con);
            }
        }

        return $modelos;  
    }
}
{% endhighlight %}
    
Como se puede ver, hay dos funciones a las que el servicio permitirá invocar. La primera de ellas *ObtenerMarcas* obtendrá todas las marcas de coches que tengamos en nuestra base de datos. La segunda función *ObtenerModelos* devolverá todos los modelos disponibles del identificador de la marca pasada como argumento. El código de las funciones creo que no merece la pena comentarlo ya que es muy básico.

Una vez que tenemos esta clase creada, nos queda hacer que el servicio atienda las peticiones y de las respuestas apropiadas. Para ello crearemos un nuevo fichero al que llamaremos *webservice.php*. En él pondremos el siguiente código:


{% highlight php linenos %}
<?php   
include 'GestionAutomoviles.class.php';

$soap = new SoapServer(null, array('uri' => 'http://localhost/'));   
$soap->setClass('GestionAutomoviles');   
$soap->handle();
?>
{% endhighlight %}
   
   
Incluiremos la clase creada anteriormente, después nos crearemos un objeto del tipo [SoapServer](http://www.php.net/manual/es/class.soapserver.php). El primer parámetro lo ponemos a *null* porque como he mencionado antes no vamos a usar ningún fichero WSDL, el segundo parámetro es un array con distintas opciones de las cuales, al no tener fichero WSDL, la única que es obligatoria es la uri. Posteriormente con el método **setClass** indicamos cual es la clase que contendrá los métodos que va a ofrecer el servicio y por último con el método **handle** se procesan las peticiones SOAP que lleguen.

En este momento nos queda ver como podemos consumir este servicio. Para ello vamos a crearnos un nuevo fichero al que llamaremos *cliente.php*. En él pondremos el siguiente código:

{% highlight php linenos %}

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Ejemplo de uso de servicio web</title>
</head>
<body>
    <?php
        $client = new SoapClient(null, array(
            'uri' => 'http://localhost/'
            'location' => 'http://localhost/webservice/webservice.php'
            )
         );

         $marcas = $client->ObtenerMarcas()
    ?
    <h1>Listado de marcas y modelos disponibles</h1>
    <ul>
        <?php
            foreach($marcas as $key => $value )
        ?>
            <li><?php echo $value; ?>
                <ul
                    <?php
                        $modelos = $client->ObtenerModelos($key)
                        foreach($modelos as $m) 
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
</body>
</html>
{% endhighlight %} 

Si quitamos todo el código html usado para presentar la salida, las lineas que nos interesan son la 10, 16 y 26. En ellas creamos un objeto del tipo [SoapClient](http://www.php.net/manual/es/class.soapclient.php). Al igual que hemos hecho con el servicio, el primer parametro es *null* porque no usamos ningún fichero WSDL, en el array de opciones tenemos que poner de nuevo la uri y la url (location) de donde esta escuchando el servicio. Una vez realizado esto ya podemos llamar a los métodos como se muestra posteriormente.

Si hubiésemos usado ficheros WSDL la creación y utilización del servicio sería igual, lo único que tendríamos que cambiar es la llamada a los constructores  de *SoapClient* y *SoapServer* que sería de la siguiente forma:

{% highlight php linenos startinline=true %}
// El servidor lo creariamos asi
$soap = new SoapServer('rutal/al/fichero.wsdl');

// El cliente seria asi
$client = new SoapClient('ruta/al/fichero.wsdl');
{% endhighlight %}

La *ruta/al/fichero.wsdl* puede apuntar tanto a un fichero local como a una url.

Como hemos podido ver hemos creado un servicio web muy sencillo y en muy pocos pasos. Mas adelante crearé una entrada para crear y usar servicios usando ficheros WSDL.

**Actualización:** Para crear el servicio web con un fichero WSDL puedes ver la entrada [Servicio Web en PHP con Zend](/2011/03/14/servicio-web-php-zend.html).