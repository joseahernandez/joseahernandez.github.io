---
layout: post
comments: false
title: Crear un plugin en JQuery
---

[JQuery](http://jquery.com/) es una librería muy útil y fácil de usar para todo el desarrollo JavaScript que tengamos que hacer en una página web. Gracias ha ella podemos desarrollar de manera más rápida que si lo hiciéramos usando simplemente JavaScript. Además cuenta con una gran cantidad de plugins para realizar casi cualquier cosa que puedas imaginar. Estos plugins al igual que la libreria son bastante sencillos de utilizar, además si lo necesitamos también podemos crearnos nuestro propio plugin. Sobre la creación de un plugin de JQuery es de lo que tratará esta entrada, así que vamos a ponernos manos a la obra.


Para comenzar veamos una imagen del resultado final que vamos a obtener. La funcionalidad del plugin será abrirnos un popup en el que seleccionaremos elementos de una lista que previamente le abremos pasado y al pulsar el botón Aceptar los elementos seleccionados aparecerán en la capa a la cual le apliquemos el plugin. Quizas no tenga mucho sentido el plugin, pero nos sirve de ejemplo para poder realizar mas adelante algo más complejo.

![](/uploads/posts/images/seleccion-jquery.jpg)

<!--more-->

Ahora que ya sabemos como tiene que quedar vamos a comenzar a programar, primeramente nos creamos un archivo donde almacenaremos nuestro plugin, yo lo he llamado seleccion.js en el escribimos las siguiente lineas:

``` javascript
(function ($) {
  $.fn.seleccion = function () {
    /* código del plugin */
  };
})(jQuery);
```

Esta es la forma en la que vamos a declarar nuestro plugin. La linea *$.fn.seleccion = function() { };* es la declaración de la función que va a realizar nuestro plugin, dentro de ella programaremos todo nuestro código. El resto de lineas *(function ($){ ... })(jQuery);* hacen que el plugin no tenga problemas con otras librerias que utilicen el símbolo del $.

Nuestro plugin únicamente va a tener dos métodos, el constructor (metodo init) que se ejecutará cuando se llama al plugin por primera vez y un método que nos permitirá cargar los datos en la lista. Este segundo método, como podemos ver, recibe un parametro que nos indicará cual es la capa (elemento div) sobre la que trabajará esta función. Además de los métodos, tendremos unas propiedades que se podrán inicializar cuando se llame al plugin o que tomarán unos valores por defecto y le darán comportamiento al plugin. Todo esto lo declaramos en nuestro fichero de la siguiente forma:

``` javascript
(function ($) {
  var propiedades = {
    "datos": "",
    "ancho": 300,
    "alto": 300
  };
  var valoresExistentes;
  var methods = {
    init: function(parametros) { /* código del método */ },
    cargarDatos: function(destino) { /* código de método */ }
  };
  $.fn.seleccion = function () {
    /* código del plugin */
  };
})(jQuery);
```

En la declaración de la variable propiedades indicamos cuales son los campos que se podrán inicializar en el constructor del plugin. En este caso serán: los datos que tenga que mostrar en la lista, el ancho y el alto con el que queremos que se muestre. Además también tenemos un array llamado *valoresExistentes*, que se encargará de almacenar los valores que se han seleccionado.

Ahora añadimos en el cuerpo de la función que va ha ejecutar nuestro plugin las acciones que queremos que realice quedándonos de la siguiente manera:

``` javascript
$.fn.seleccion = function (method) {
    if (methods[method]) {
        return methods[method].apply(this, 
            Array.prototype.slice.call(arguments, 1));
    } else if (typeof method === "object" || !method) {
        return methods.init.apply(this, arguments);
    } else {
        $.error("El metodo " + method + " no existe en el plugin selector");
    }
};
```

Este código se encargará de llamar a los métodos correspondientes según los parametros con los que invoquemos al plugin. En el primer *if* comprobaremos si existe un metodo en nuestro atributo *methods* con el nombre que hemos indicado. En caso de que exista lo llamará pasandole los parametros que posteriormente le hayamos indicado en la llamada. Si no existe ningún metodo con ese nombre, se llamará al metodo *init* al cual también le pasaremos parametros si los hemos indicado en la llamada. Por último si no existe ningún método y tampoco se está llamando a init, mostraremos un mensaje de error. Un ejemplo de posibles llamadas para el plugin podrían ser las siguientes:

``` javascript
$("div").seleccion(); // Llama al metodo init
$("div").seleccion({ ancho: 400 }); // Llama al metodo init con un parametro

// Llama al metodo cargarDatos con un parametro
$("div").seleccion("cargarDatos", "parametro");
```

Pasemos ahora al trabajo duro. Comenzaremos por la funcion *cargarDatos* que es mas sencilla, el código es el siguiente:

``` javascript
cargarDatos: function(destino) {
    destino.children().remove();
    // Creamos una tabla donde pondremos todas las opciones disponibles
    var table = $("<table border='0' cellpadding='0' 
        cellspacing='0'></table>");
    // Recorremos los datos que hemos pasado para ir rellenando la tabla
    for(var i = 0; i < propiedades.datos.length; i++) {
        // En principio el checkbox no estará seleccionado
        var check = false;

        // Miramos si el elemento que vamos a incluir en la lista ya esta 
        // contenido en el vector de elementos existentes
        for(var j = 0; j < valoresExistentes.length; j++)
            // Si esta contenido marcaremos el checkbox como seleccionado
            if( propiedades.datos[i].nombre == valoresExistentes[j]) {
                check = true;
                break;
            }
        // Creamos un elemento checkbox y inicializamos su 
        // propiedad checked
        var checkbox = $("<input type='checkbox' id='item-" + 
            i + "'/>").attr("checked", check);
        // Cada vez que cambie el estado de un checkbox ejecutamos 
        // la siguiente función    
        checkbox.change(function() {
            // Si hemos seleccionado el elemento lo guardamos en el 
            // vector de elementos existentes
            if( $(this).attr("checked") == true )
                valoresExistentes.push($(this).parent()
                    .siblings().html());
            else {
                // Si lo hemos deseleccionado, lo buscamos entre el 
                // vector de elementos existentes
                for(var k = 0; k < valoresExistentes.length; k++)
                    if( valoresExistentes[k] == $(this).parent()
                            .siblings().html()) {
                        // Cuando encontramos el elemento que hemos 
                        // desmarcado, lo eliminamos del vector
                        valoresExistentes.splice(k, 1);
                        break;
                    }
            }
        });
        // Añadimos a la tabla una fila con dos celdas, la primera 
        // con el checkbox y la segunda con el nombre del elemento
        table.append($("<tr></tr>")
            .append($("<td></td>")
            .append(checkbox))
            .append($("<td></td>")
            .append(propiedades.datos[i].nombre)))               
    }
    // Por último añadimos la tabla a la capa que pasamos como argumento.
    destino.append(table);
}
```

Una vez que tenemos claro cual es el trabajo que realiza esta función pasemos a ver la que nos queda, la funcion *init*:

``` javascript
init: function(parametros) {
    // Comprobamos si ya existe un elemento con el mismo id, es caso 
    // afirmativo finalizamos
    if( $("#sel-" + $(this).attr("id")).html() != null ){
        return;
    }
    
    // Si se han pasado parametros, machacamos los valores existentes en 
    // propiedades
    if (parametros) {
        $.extend(propiedades, parametros);
    }
    
    // Creamos el vector que almacenará los valores seleccionados
    valoresExistentes = Array();
    
    // Buscamos los elementos que ya existen en el div y los añadimos 
    // al vector
    $(this).find("li").each(function() {
        valoresExistentes.push($(this).html());
    });
    
    // Creamos los objetos a partir de la cadena JSON
    if( propiedades.datos != "" )
    propiedades.datos = JSON.parse(propiedades.datos);
    
    // Para cada elemento al que le apliquemos el plugin hacemos lo siguiente
    this.each(function(){
        // Creamos un div donde mostraremos el control que vamos a crear y 
        // le asignamos las propiedades por defecto o bien las pasadas por 
        // el usuario
        var contenedor = $("<div id='sel-" + $(this).attr("id") + "'></div>")
                .css("width", propiedades.ancho)
                .css("height", propiedades.alto)
                .addClass("contenedor");
        
        // Le ponemos un titulo
        contenedor.append($("<p class='titulo'>Seleccione los elementos</p>"));
        
        // Hacemos que al pinchar en el titulo podemos arrastrar el control 
        // por toda la ventana
        contenedor.draggable({handle: ".titulo"});
        
        // Creamos el input que nos servirá de filtro
        var textbox = $("<input type='text' name='filtro' value='' 
                class='filtro'/>");
        
        // Después de pulsar un tecla lanzamos el siguiente evento, esto solo 
        // se ejecutará al escribir en el input
        textbox.keyup(function() {
            // Si el input está vacio llamamos al metodo de cargarDatos visto 
            // anteriormente
            if( $(this).val() == "" )
            // Le decimos que la capa con la clase "lista" será donde tiene 
            // que crear los controles
            methods.cargarDatos(contenedor.find(".lista"));
            else {
                // El input tiene datos, lo primero que hacemos es limpiar 
                // los controles de la lista
                contenedor.find(".lista").children().remove();
                // Creamos de nuevo la tabla
                var table = $("<table border='0' cellpadding='0' 
                    cellspacing='0'></table>");
                
                // Recorremos todos los datos
                for(var i = 0; i < propiedades.datos.length; i++) {
                    // Si el dato actual comienza por los mismos caracteres 
                    // que hay escritos en el input lo añadiremos a la tabla
                    if( propiedades.datos[i].nombre
                        .substr(0, $(this).val().length).toLowerCase() == 
                          $(this).val().toLowerCase() ) {
                        var check = false;
                        
                        // Comprobamos si está en el vector de valores existentes
                        for(var j = 0; j < valoresExistentes.length; j++) {
                            if( propiedades.datos[i].nombre == 
                                    valoresExistentes[j]){
                                // En caso de que esté lo marcaremos como seleccionado
                                check = true; 
                                break;
                            }
                        }
                        // Creamos el checkbox
                        var checkbox = $("<input type='checkbox' id='item-" 
                            + i + "' />");
                        checkbox.attr("checked", check);
                        // Al cambiar el estado del checkbox lo añadimos 
                        // o borramos del vector de valores existentes
                        checkbox.change(function() {
                            if( $(this).attr("checked") == true )
                            valoresExistentes.push($(this).parent()
                                .siblings().html());
                            else {
                                for(var k = 0; k < valoresExistentes.length; 
                                    k++)
                                if( valoresExistentes[k] ==
                                        $(this).parent().siblings().html()) {
                                    valoresExistentes.splice(k, 1);
                                    break;
                                }
                            }
                        });
                        // Añadimos una fila a la tabla con el checkbox y el 
                        // nombre del elemento actual
                        table.append($("<tr></tr>").append($("<td></td>")
                            .append(checkbox)).append($("<td></td>")
                            .append(propiedades.datos[i].nombre)))
                    }
                }
                // Añadimos la tabla en el div con la clase "lista"
                contenedor.find(".lista").append(table);
            }
        });
        
        // Una vez finalizada la acción que hay que realizar al pulsar una
        // tecla seguimos creando el control Añadimos el input antes creado
        contenedor.append(textbox);
        // Añadimos el div con la clase "lista" que es donde mostraremos 
        // la tabla con los checkbox
        contenedor.append("<div class='lista'></div>");
        
        // Llamamos al metodo cargarDatos para mostrar todos los datos 
        // pasados
        methods.cargarDatos(contenedor.find(".lista"));
        
        // Creamos un boton cancelar que simplemente cerrara el control
        var cancelar = $("<input type='button' name='cancelar' 
            value='Cancelar' />");
        cancelar.click(function() {
            // Aplicamos un efecto y al finalizar eliminamos el control
            $(contenedor).slideUp("slow", function() {
                $(contenedor).remove();
            });
        });
        
        // Almacenamos el objeto actual porque dentro de una funcion JQuery el 
        //atributo this se refiere al elemento al que se le está aplicando la función
        var __this = this;
        // Creamos el boton aceptar
        var aceptar = $("<input type='button' name='aceptar' value='Aceptar' />");
        
        aceptar.click(function() {
            // Al pulsar aceptar creamos una lista
            var ul = $("<ul></ul>");
            
            // Le añadimos a la lista todos los elementos que se han seleccionado
            for(var i = 0; i < valoresExistentes.length; i++)
            ul.append("<li>" + valoresExistentes[i] + "</li>")
            
            // Borramos todo el contenido de la capa a la que se le está aplicando 
            // el plugin
            $(__this).children().remove();
            // Le añadimos la nueva lista a la capa
            $(__this).append(ul);
            
            // Hacemos un efecto para que se cierre y eliminamos el control
            $(contenedor).slideUp("slow", function() {
                $(contenedor).remove();
            });
        });
        
        // Añadimos los botones creados antes al control
        contenedor.append($("<p class='derecha'></p>").append(cancelar)
            .append("&amp;nbsp;").append(aceptar));
        contenedor.css("display", "none");
        // Mediante un efecto mostramos el control creado
        $("body").append(contenedor.slideDown("slow"));
    });
    
    // Devolvemos this porque de esta forma podemos encadenar llamadas a 
    // funciones JQuery
    return this;
}
```

Con esto tenemos finalizado nuestro pequeño plugin en JQuery, ahora unicamente aplicandole unos estilos con una css obtendriamos el aspecto visual que quisieramos. En mi caso yo le he aplicado los siguientes estilos para lograr el aspecto final:

``` css
.contenedor {
    border: 3px solid #5993EF;
    padding: 4px; 
    background: #C3D9FF; 
    position: fixed;
    top: 10%;
    left: 30%;
    z-index: 9999;
}

.titulo {
    background: #5993EF;
    margin: -4px -4px 8px -4px; 
    padding-bottom: 2px; 
    color: #FFFFFF;
}

.filtro { width: 100% }

.lista {
    overflow: auto;
    height: 65%; 
    border: 1px solid #FFEE88; 
    margin: 4px auto; 
    background: #FFFFFF; 
}

.derecha { text-align: right; }
```

Para finalizar nos quedaria enlazarlo todo en la página donde vayamos a utilizarlo y llamar a nuestro plugin. Aquí dejo el ejemplo que he usado yo para realizar el plugin:

``` html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" 
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <script type="text/javascript" src="jquery.js"></script>
    <!-- Enlazo JQuery-UI para permitir mover el control por el navegador -->
    <script type="text/javascript" src="jquery-ui-1.8.5.custom.min.js">
    </script>
    <script type="text/javascript" src="prueba.js"></script>

    <link rel="stylesheet" href="seleccion.css" />

    <title>Ejemplo Plugin en JQuery</title>

  </head>
  <body>

    <p style="margin-bottom: 2px;">Lista de frutas:</p>
    <div id="capa"></div>
    <p style="width: 200px; text-align:right; margin-top: 4px;">
      <input type="button" name="seleccion" id="selecciona" 
      value="Selecciona" />
    </p>

    <script type="text/javascript">
      $(document).ready(function() {
        var datos = "[{"nombre": "Manzanas"}, {"nombre": "Naranjas"}, 
            {"nombre": "Kiwis"},{"nombre": "Moras"},{"nombre": "Uvas"},
            {"nombre": "Mandarinas"},{"nombre": "Sandias"}, 
            {"nombre": "Melocotones"},{"nombre": "Peras"}, 
            {"nombre": "Fresas"}, {"nombre": "Platanos"}, 
            {"nombre": "Melones"}]";

        $("#selecciona").click(function(){
          $("#capa").seleccion( { "datos": datos });
        });
      });
    </script>
  </body>
</html>
```

Con todos los pasos anteriores hemos finalizado con el desarrollo de un plugin JQuery, si quieres descargar el código del ejemplo puedes hacerlo desde [aquí](/uploads/posts/samples/plugin-jquery.rar).