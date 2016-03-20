---
layout: post
comments: false
title: Desplegar aplicación web ASP MVC en IIS
---

Cuando estamos desarrollando una aplicación con ASP MVC un requisito bastante importante que tenemos que conocer es el servidor web donde se va a desplegar nuestra aplicación. Lo normal es que este sea un IIS (Internet Information Server), pero dependiendo de su versión puede que tengamos que realizar algunos cambios en nuestra aplicación para que todo funcione correctamente.

Si el servidor es IIS 7 tenemos que saber si está en el modo clásico o el modo integrado. Para ello arrancamos el Internet *Information Services Manager* y vamos a la ventana *Connections*. En ella seleccionamos una aplicación cualquiera y hacemos clic en *Basic Settings* para ver la configuración de la aplicación. Si nos fijamos en *Application pool* pueden aparecer dos valores:

* DefaultAppPool nos indica que estamos en el modo integrado.
* Classic .NET AppPool estamos en el modo clásico.

Si estamos en el modo integrado no tendremos que realizar ninguna modificación ya que nuestro servidor soporta por defecto ASP MVC. En cambio si estamos en el modo clásico tendremos que cambiarlo seleccionando el botón *Select*. Esto puede hacer que perdamos la compatibilidad con las aplicaciones desarrolladas en versiones antiguas de .NET.

<!--more-->

Si el servidor es una versión anterior, IIS 5 o IIS 6, tenemos dos posibilidades para hacer que funcionen las aplicaciones. La primera que voy a explicar requiere la modificación de las url para añadirle la extensión **.aspx**. Lo que significa que nuestras url tendrán la siguiente forma:

``` none
/Home.aspx
/Home.aspx/About
/Account.aspx/LogOn
```

Lo positivo de esta forma es que no requiere realizar ningún tipo de modificación en el IIS, lo cual puede ser interesante si no tenemos la posibilidad de acceder a él porque tenemos contratado el servicio con una empresa externa. Por otra parte, lo negativo es que las url no quedan completamente limpias ya que siempre aparece la extensión aspx. Para realizar este cambio tenemos que acceder al fichero **Global.asax** y modificar el método **RegisterRoutes** de esta forma:


``` csharp
public static void RegisterRoutes(RouteCollection routes)
{
  routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

  routes.MapRoute(
      "Default",
      "{controller}.aspx/{action}/{id}",
      new { action = "Index", id = "" }
    );

  routes.MapRoute(
      "Root",
      "",
      new { controller = "Home", action = "Index", id = "" }
    );
}
```

Simplemente con este cambio ya hemos conseguido que nuestra aplicación funcione en una versión inferior a la 7 en IIS. Hay que tener en cuenta que si dentro de nuestra aplicación hemos creado algún enlace sin utilizar el helper **Html.ActionLink()** tendremos que revisar estos enlaces para que contengan la extensión .aspx. Los enlaces creados con el helper anterior ya lo tendrán por defecto.

La otra posibilidad que tenemos para que las aplicaciones ASP MVC funcionen en IIS 5 o IIS 6 es realizar una modificación en el servidor para que pueda mapear correctamente las url. Esta opción tiene la ventaja de que nos permite dejar las url limpias, pero como desventaja tiene un impacto importante en el rendimiento de la aplicación porque todas las solicitudes tanto de imágenes, paginas html y contenido estático pasarán por el servidor.

Para realizar esta modificación abrimos el IIS y vamos a nuestra aplicación, pulsamos el botón derecho y vamos a *Propiedades*. En la pestaña *Directorio virtual* pulsamos el botón *Configuración*. En la nueva ventana que nos aparece y dentro de la pestaña *Asignaciones* pulsamos *Agregar*. En la ruta del ejecutable tenemos que indicar donde se encuentra el fichero **aspnet_isapi.dll** en el servidor. En mi caso está en la ruta *C:\\WINDOWS\\Microsoft.NET\\Framework\\v4.0.30319\\aspnet_isapi.dll*. Si nos pide la extensión pondremos **.*** para indicar que lo analice todo, por último desmarcamos la casilla **Comprobar si el fichero existe** y aceptamos en todas las ventanas. Con esto hemos conseguido que nuestra aplicación ASP MVC funcione correctamente y sin modificar las url.

Esta última opción también es posible realizarla en el servidor IIS 7 en modo clásico por si no se quiere perder la compatibilidad con versiones anteriores. Pero hay que recordad que hay una penalización en el rendimiento de la aplicación al tener el servidor que procesar todas las solicitudes que recibe.