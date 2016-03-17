---
layout: post
comments: false
title: Plugin jQuery para Google Maps
---

gMaps es un plugin para jQuery que permite mostrar mapas de Google Maps y personalizarlos de una forma sencilla. El plugin ha sido desarrollado por [Sebastian Poręba](http://www.smashinglabs.pl/) y podemos ver toda la información relacionada con el plugin en su [blog](http://www.smashinglabs.pl/gmap).


Para comenzar a trabajar con este plugin, simplemente tenemos que cargar en nuestra página web las librerías del [Api de Google Maps](http://maps.google.com/maps/api/js?sensor=false), [jQuery](http://jquery.com/) y el propio [plugin gMaps](https://github.com/fridek/gmap). Un primer ejemplo sencillo lo podemos ver a continuación, con el siguiente código podemos crear un mapa centrado en Valencia, España.

<!--more-->

{% highlight html linenos %}
<!DOCTYPE html>
  <head>
    <title>Mapa</title>
  </head>
  <body>
    <div id="map" style="width: 800px; height: 600px; border: 1px solid #777; 
                              overflow: hidden; margin: 0 auto;"></div>

    <script type="text/javascript" 
         src="http://maps.google.com/maps/api/js?sensor=false"></script>
    <script type="text/javascript" src="js/jquery.js"></script>
    <script type="text/javascript" src="js/jquery.gmap.js"></script>	
    
    <script type="text/javascript">
      $(document).ready(function() {
        $(''#map'').gMap({ address: ''Valencia, Spain'', zoom:14 });
      });
    </script>
  </body>
</html>
{% endhighlight %}

![Mapa Valencia](/uploads/posts/images/gMap-sample1.png)

**Nota:** *El mapa anterior, al igual que el resto de mapas que muestre son imágenes estáticas, pero al final de la entrada publicaré el enlace donde se podrá descargar el código con todos los ejemplos funcionando correctamente.*

Pero este plugin no se queda únicamente aquí, supongamos que queremos indicar mediante un marcador la localización de la estación del Norte (estación de trenes de Valencia). Para ello simplemente tendremos que mantener el mismo código mostrado anteriormente, actualizando únicamente el código de la llamada al plugin gMaps por este otro:

{% highlight javascript linenos %}
$(document).ready(function() {
    $('#map').gMap({ 
        markers: [
            {latitude: 39.467019, longitude: -0.377135}
        ], 
        zoom: 16 
      });
  });
{% endhighlight %}

![Mapa estación Norte Valencia](/uploads/posts/images/gMap-sample2.png)

En un mapa podemos poner tantos marcadores como queramos, para hacerlo simplemente tenemos que pasarle una lista con la longitud y latitud de todos los marcadores. En el siguiente ejemplo podemos ver tres estaciones de trenes que se encuentran en la ciudad de Valencia.

{% highlight java linenos %}
$(document).ready(function() {
    $('#map').gMap({ 
        markers: [
            {latitude: 39.467019, longitude: -0.377135}, 
            {latitude: 39.440038, longitude: -0.366122},
            {latitude: 39.470046, longitude: -0.334655}
        ], 
       zoom: 13 
   });
});
{% endhighlight %}

![Mapa estaciones tren Valencia](/uploads/posts/images/gMap-sample3.png)

La sencillez con la que podemos realizar cualquier tipo de acción en Google Maps con este plugin es increíble, para finalizar vamos a ver como podemos personalizar el icono de marcador por uno propio, haremos que aparezca un popup con información cuando se pulse sobre él y cambiaremos el tipo de mapa a mostrar. El código para realizar esto es el siguiente:

{% highlight java linenos %}
$(document).ready(function() {
    $('#map').gMap({ 
        markers: [
            {
                latitude: 39.467019, 
                longitude: -0.377135,
                html: 'Estación del Norte'
            }, 
            {
                latitude: 39.440038, 
                longitude: -0.366122,
                html: 'Estación Fuente San Luis'
            },
            {
                latitude: 39.470046, 
                longitude: -0.334655,
                html: 'Estación el Cabañal'
            }
        ], 
        zoom: 13,
        icon : { image: 'favicon.png' },
        maptype: google.maps.MapTypeId.SATELLITE
    });
});
{% endhighlight %}

![Estaciones trenes con marcadores personalizados](/uploads/posts/images/gMap-sample4.png)

Bastante sencillo ¿no? hay que indicar que cada marcador también podría ser personalizado con un icono distinto, simplemente añadiendo el nodo *icon: ...* dentro de las llaves en las que definimos el marcador. Además en el texto que hemos indicado que aparezca en el popup al pulsar el marcado, podemos introducir código HTML para poder personalizar más el popup. Estas son solo algunas de las cosas que podemos hacer con este plugin, si necesitas realizar alguna otra cosa, puedes darle un vistazo a la [documentación](http://www.smashinglabs.pl/gmap/documentation) donde seguro que encuentras como hacerlo.

Para descargar todos los ejemplos puedes hacerlo desde este [enlace](/uploads/posts/samples/ejemplo-uso-gmap-plugin.zip).