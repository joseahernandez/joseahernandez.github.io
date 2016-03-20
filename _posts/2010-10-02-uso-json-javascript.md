---
layout: post
comments: false
title: Uso de JSON con JavaScript
---

JSON es un formato de datos muy utilizado para el intercambio de información entre aplicaciones o entre clientes y servidores. Tiene aplicación en muchos casos, pero sobretodo es usado en las respuestas a peticiones AJAX. Un ejemplo muy básico de una cadena JSON podría ser el siguiente:

``` json
[
  {"Titulo": "El señor de los anillos", "Autor": "J.R.R. Tolkien"}, 
  {"Titulo": "Cancion de hielo y fuego", "Autor": "George RR Martin"}, 
  {"Titulo": "Los Pilares de la Tierra", "Autor": "Ken Follett"}
]
```
 
Como podemos ver tenemos una colección de tres libros y cada uno de ellos contiene su título y el nombre de su autor. La forma de trabajar con estos datos desde JavaScript seria la siguiente:

``` javascript
var cadenaLibros = '[
    {"Titulo": "El señor de los anillos", "Autor": "J.R.R. Tolkien"}, 
    {"Titulo": "Cancion de hielo y fuego", "Autor": "George RR Martin"}, 
    {"Titulo": "Los Pilares de la Tierra", "Autor": "Ken Follett"}
]';

var libros = JSON.parse(cadenaLibros);

for(var i = 0; i < libros.length; i++ )
  alert('El libro: ' + libros[i].Titulo + ' es del autor: ' + libros[i].Autor);
```


<!--more-->

Con la función *JSON.parse()* convertimos la cadena en un array de objetos. Después con el bucle recorremos el array y mostramos el título y el autor de cada libro accediendo a ellos como propiedades. Bastante sencillo &iquest;no? Vamos ahora a complicar un poco más el asunto. Supongamos que tenemos la siguiente cadena JSON:

``` json
[
    {
        "Titulo": "El señor de los anillos", "Autor": "J.R.R. Tolkien", 
        "Partes": [
            {"Tomo": 1, "Titulo": "La comunidad del anillo"}, 
            {"Tomo": 2, "Titulo": "Las dos torres"}, 
            {"Tomo": 3, "Titulo": "El retorno del rey"}
         ]
    },
    {
        "Titulo": "Cancion de hielo y fuego", "Autor": "George RR Martin", 
        "Partes": [
            {"Tomo": 1, "Titulo": "Juego de tronos"}, 
            {"Tomo": 2, "Titulo": "Choque de reyes"}, 
            {"Tomo":3, "Titulo": "Tormenta de espadas"}, 
            {"Tomo": 4, "Titulo": "Festín de cuervos"}
        ]
    }, 
    {
        "Titulo": "Los Pilares de la Tierra", 
        "Autor": "Ken Follett"
    }
]
```
 

Ahora vemos que algunos libros contienen "partes" dentro de ellos, separando los distintos tomos con los que cuenta cada uno. Lo que vamos a realizar ahora es mostrar estos datos creando una lista con la ayuda de JQuery.

``` javascript
var cadena = "[{ ... }]"; // Usamos la cadena anterior
var libros = JSON.parse(cadena);

var ul = $("<ul></ul>"); // Creamos un elemento ul

for( var i = 0; i < libros.length; i++ ) {
  var li = $("<li></li>")// Creamos un elemento li 
  // Añadimos el titulo y el autor al elemento li
  li.append(libros[i].Titulo + " (" + libros[i].Autor + ")"); 

  // Comprobamos si el libro tiene partes
  if( libros[i].Partes != undefined && libros[i].Partes.length > 0 ) {
    var ulInterno = $("<ul></ul>"); // Creamos otro elemento ul

    for( var j = 0; j < libros[i].Partes.length; j++ ) {
      // Por cada parte crearemos un elemento li que añadiremos al ul 
      // que acabamos de crear
      ulInterno.append("<li>" + libros[i].Partes[j].Tomo + " - " + 
        libros[i].Partes[j].Titulo + "</li>"
      );
    } 
    // Añadimos el último elemento ul al li creado primero
    li.append(ulInterno);  
  }
  ul.append(li); // Añadimos el li inicial al ul inicial. 
} 
$("body").append(ul); // Añadimos la lista al body de la pagina
```


Con estos sencillos pasos hemos conseguido crearnos una lista con todos los libros de nuestra colección. El código creo que es bastante sencillo y con los comentarios no requiere ninguna explicación más.

A parte de la función JSON.parse() que es la fundamental para realizar la transformación entre la cadena JSON y un array de objetos hay otra función que no se ha usado, pero que cabe mencionar. Se trata de la función *JSON.stringify()* esta función realiza la tarea inversa a la anterior. Es decir convierte un objeto en una cadena. Un ejemplo se puede ver si ejecutamos lo siguiente:

``` javascript
var nuevaCadena = JSON.stringify(libros);
alert(nuevaCadena);
```


El resultado será la cadena original que pasamos al principio. Con esto último termino la entrada de hoy, otro día contaré más cosas para trabajar con el formato JSON.
