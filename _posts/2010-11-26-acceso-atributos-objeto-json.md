---
layout: post
comments: true
title: Acceder a los atributos de objetos JSON
date: 2010-11-26 10:43:00
---

El otro día hable sobre como podíamos usar [JSON de una forma sencilla](/2010/02/10/uso-json-javascript.html) en una web. Ahora vamos a dar un paso más y veremos otro uso que podemos hacer con el formato JSON. Hoy veremos cómo podemos **obtener el nombre de los atributos de un objeto JSON**.

Supongamos que tenemos una función en JavaScript que nos crea una tabla a partir de una cadena recibida en formato JSON. Esto no tendría que ser ningún problema si conocemos un poco de JavaScript o si hemos leído la entrada antes mencionada. Pero si lo piensas bien, siempre tendríamos que pasar la misma estructura de los datos para poder acceder a ellos con la notación que nos proporciona JavaScript para ello *(objeto.atributo)* Además la cabecera de la tabla siempre sería la misma, cosa que en algunas ocasiones no nos interesará.

Lo primero que vamos a ver es como obtener los atributos de un objeto JSON. Para ello utilizaremos el siguiente código:

{% highlight javascript linenos %}
var cadena = // Cadena con formato JSON

var valores = JSON.parse(cadena);
if( valores.length > 0 ) {
  var atributos = "";
  for(var aux in valores[0])
    atributos += aux + " ";

  alert("Los atributos son: " + atributos);
}
else
  alert("No hay datos");
{% endhighlight %}

<!--more-->

Los pasos que realiza el código anterior son los siguientes: convierte la cadena en objetos, si la cadena contiene algún objeto con la ayuda de un bucle recorremos sus atributos y los vamos concatenando en la variable atributos. Por último mostramos un mensaje con los atributos del objeto.

Una vez que sabemos cómo obtener los atributos de un objeto las cosas van pareciendo más claras, pero ¿cómo podemos acceder a la propiedad de un objeto teniendo almacenado su nombre en una variable? Para solucionar este problema tenemos la función **eval()** de JavaScript. Esta función evalúa el contenido que le pasemos como parámetro como si fuera una expresión, de forma que si tenemos un objeto *(obj)* que tiene un función *(ejemplo)* y tenemos el nombre de esa función almacenado en una variable *(var aux = "ejemplo")* para llamar a esa función podemos hacerlo de esta forma: **eval("obj." + aux)**

Una vez que tenemos en mente estos pasos vamos a crear nuestra función para generar nuestra tabla.

{% highlight javascript linenos %}
function generarTabla(datos) {
  if( datos != '' ) {
    var i;
    var valores = JSON.parse(datos);
    var atributos = Array();
    
    if( valores.length > 0 ) {
      for( var aux in valores[0] )
        atributos.push(aux);
    }
    var tabla = $('<table border="1" cellspacing="0" cellpadding="2"></table>');
    var head = $('<tr></tr>').css('text-transform', 'capitalize');
    for( i = 0; i < atributos.length; i++) {
      head.append('<th>' + atributos[i] + '</th>');
    }
    tabla.append($('<thead></thead>').append(head));

    var tbody = $('<tbody></tbody>');
    for(i = 0; i < valores.length; i++ ) {
      var tr = $('<tr></tr>');
      for(j = 0; j < atributos.length; j++ )
        tr.append('<td>' + eval('valores[i].' + atributos[j]) + '</td>');

      tbody.append(tr);
    }
    tabla.append(tbody);
    $('body').append(tabla);
  }
}
{% endhighlight %}

Lo primero que hacemos es obtener los atributos del objeto y guardarlos en un array. Posteriormente creamos la tabla con ayuda de JQuery y vamos formando la cabecera recorriendo el array anterior y añadiendo una celda por cada atributo. Cuando tenemos la cabecera pasamos al cuerpo de la tabla. Recorremos todos los datos y todos los atributos que tiene cada dato. Añadimos el valor del atributo usando para acceder a él la función eval y lo vamos añadiendo en filas que posteriormente añadiremos al tbody de la tabla. Por ultimo añadimos el tbody a la tabla y ponemos la tabla en el body de la página html.

Si le pasamos alguna de las siguientes cadenas a nuestra función, obtendremos una tabla con los datos de la cadena pasada.

{% highlight javascript linenos %}
var libros = "[
    {"titulo": "La caida de los gigantes", "autor": "Ken Follet"}, 
    {"titulo": "Aqueron", "autor": "Sherrilyn Kenyon"},
    {
        "titulo": "Los hombres que no amaban a las mujeres", 
        "autor": "Stieg Larsson"
    }
]";

var alumnos = "[
    {"nombre": "Juan", "calificacion": 6}, 
    {"nombre": "Sara", "calificacion": 8},
    {"nombre": "Paco", "calificacion": 5}
]";
{% endhighlight %}