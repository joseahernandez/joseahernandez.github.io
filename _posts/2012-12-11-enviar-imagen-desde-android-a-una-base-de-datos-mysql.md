---
layout: post
comments: false
title: Enviar imagen desde Android a una base de datos MySQL
---

En la entrada que realice para [obtener una imagen almacenada en MySQL desde una aplicación Android](/2012/08/16/obtener-imagen-almacenada-mysql-android.html) recibí varios comentarios de como realizar el proceso inverso, es decir, poder subir una imagen desde un dispositivo Android para almacenarlo en una base de datos. Así que he decidido crear esta entrada para explicar más o menos como sería el proceso.

Lo primero que tendríamos que tener es un servicio que escuchara la petición y se encargara de almacenar la imagen en la base de datos. Este servicio podría ser de la siguiente manera:

<!--more-->

{% highlight php linenos %}
<?php

try
{
    if (isset($_POST["name"]) && isset($_POST["photo"])) 
    {
        $con = new PDO('mysql:host=localhost;dbname=cities', 'user', 'pass');
        $con->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
   
        $stmt = $con->prepare('INSERT INTO cities (name, photo) VALUES ' .
            '(:name, :photo)');
        $rows = $stmt->execute( array( 
            ':name'  => $_POST['name'],
            ':photo' => base64_decode($_POST['photo'])
        ));
    }
}
catch(PDOException $e)
{
    die('Error');
}
{% endhighlight %}

La funcionalidad que tiene es bastante sencilla, primero nos aseguramos que recibimos mediante petición POST los parámetros *name* y *photo*. A continuación, utilizando [PDO](/2012/07/01/consultas-base-datos-pdo.html) abrimos una conexión a la base de datos y realizamos la inserción de la imagen llamando previamente a la función [base64_decode](http://php.net/manual/es/function.base64-decode.php) para descodificar la información de la imagen que hemos recibido.

Una vez que hemos llegado a este punto, nos falta la aplicación Android. Para hacer mas sencillo el ejemplo, supongamos que en la carpeta *res/drawable* de nuestra aplicación tenemos una imagen llamada *berlin.jpg* y queremos que sea esta imagen la que se envíe. Para realizar esta función, pondremos un botón en nuestra aplicación y cuando se pulse se ejecutará el siguiente código:

{% highlight java linenos %}
HttpClient httpclient = new DefaultHttpClient();
// URL del servicio que almacenara la imagen
HttpPost httppost = new HttpPost("http://192.168.0.2/cities/upload.php");

// Recuperamos la imagen de los recursos
Bitmap bm = BitmapFactory.decodeResource(context.getResources(),
                R.drawable.berlin);

// Convertimos al imagen a un array de bytes
ByteArrayOutputStream stream = new ByteArrayOutputStream();
bm.compress(Bitmap.CompressFormat.JPEG, 100, stream);
byte[] byteArray = stream.toByteArray();
  
// Creamos los parámetros de la petición
List<BasicNameValuePair> nameValuePairs = new ArrayList<BasicNameValuePair>();
nameValuePairs.add(new BasicNameValuePair("name", "ejemplo"));
// Codificamos en base64 los bytes de la imagen
nameValuePairs.add(new BasicNameValuePair("photo", 
    Base64.encodeToString(byteArray, Base64.DEFAULT)));

httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));

// Ejecutamos la petición
HttpResponse response = httpclient.execute(httppost);
{% endhighlight %}

Con estos pasos ya podemos almacenar una imagen desde nuestro dispositivo Android en una base de datos MySQL.

Antes de terminar me gustaría indicar que la entrada es un ejemplo sencillo y no he tenido en cuenta muchas cosas que una aplicación final debería contemplar, como por ejemplo permitir seleccionar cualquier foto que se encuentre en el dispositivo. También hay que indicar que la petición de subida de la imagen es completamente recomendable realizarla en un hilo nuevo para no bloquear la aplicación mientras se realiza esta tarea.