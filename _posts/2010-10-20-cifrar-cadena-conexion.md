---
layout: post
comments: false
title: Cifrar cadena de conexión web.config
---

Una de las cosas más importantes a la hora de desarrollar una aplicación web es el tema de la seguridad. Tenemos que estar atentos a posibles ataques por parte de datos introducidos por usuarios malintencionados como de cualquier posible acceso a nuestro servidor donde esté alojada nuestra aplicación.

En esta entrada veremos como podemos cifrar las cadenas de conexión en los ficheros **web.config** de las aplicaciones web en ASP.NET de forma que tanto las rutas, como los usuarios y contraseñas no puedan ser descubiertos.

Supongamos que en la sección connectionStrings tenemos la siguiente cadena de conexión a una base de datos mediante el conector ODBC:

``` none
<add name="ConnectionString1" connectionString="DSN=ruta.dns;UID=usuario;
    SERVER=servidor;" providerName="System.Data.Odbc"/>
```

Para llevar a cabo el cifrado de la cadena de conexión utilizaremos el fichero **aspnet_regiis.exe**. Este fichero lo podemos encontrar en el directorio *C:\windows\microsoft.NET\Framework\v2.0.50727* Para realizar el cifrado abriremos una consola y ejecutar el siguiente comando

``` none
aspnet_regiis.exe -pef "seccion_a_cifrar" "unidad:\ruta\al\proyecto" 
    -prov "DataProtectionConfigurationProvider"
```

<!--more-->

Los parámetros que le pasamos al comando son los siguientes:

* **seccion_a_cifrar** indica que sección del web.config es la que queremos cifrar. En nuestro caso será connectionStrings

* **unidad:\ruta\al\proyecto** es la ruta completa en la que tenemos almacenado nuestro proyecto

* **DataProtectionConfigurationProvider** es el proveedor de cifrado que utilizaremos.

Un ejemplo podría ser el siguiente:

``` none
aspnet_regiis.exe -pef "connectionStrings" "C:\ProyectoCifrar" 
    -prov "DataProtectionConfigurationProvider"
```

Una vez que el proceso ha finalizado, nuestro web.config habrá sido modificado y podremos ver algo como esto:

``` none
<connectionStrings configProtectionProvider="DataProtectionConfigurationProvider">
    <EncryptedData>
        <CipherData>
            <CipherValue>AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAY+tz+qWbP0uw8iNR8rW3BQQAA
              AACAAAAAAADZgAAqAAAABAAAACVX9ZQftt2xWhfFiRwiSYQAAAAAASAAACg AAAAEAAAAC
              mYYAG3MLfRq3I6zO+2/NZgAQAAec6VLtd4WJtSnoKmB27dr6jkNy5vVVzH1yoTwYD++KP
              JF2UhcvE3UUsHRjuqUu1yapeXmT1C99DAKyXi+aeVH6tZRh/oLKon9DPuWyR2VZYGXUq0
              6EArfNLUiAi/Mtn7k05dPjkYGtXjLQJUko8vvel+mUS+ZlQXoHSDJVYb1IVHKwQf4qvjT8s
              fyxuNBRUeMHElCXV9IbEP7mZaWwX90fWOwKe+SU9e3fRH/FBtjpeUdPoUxzgWoPpQUiP
              aJ9NusuDS4jy4cSPWvhB2vUabhxL3vtneGzVyBIIwn7u9OoNT43H1jUANLfL7FQtvBJEVW
              ECs+tCJnlTKN8ula+UYYCX4+AvKRPaEzxOkSHFS80bbiRJI6oNIG3K7vMmumbB6b6KRA0h
              tZGdtaYtYKPPXovdoKo9qsfugWKoD5asC0n69x4p6xhgCfX5kCvBj+eyChQwLAkGDcF7
              dCgxzK9xQAAAB+L2rTfySbpOT+s7Yk+kh6xtU4cQ==</CipherValue>
        </CipherData>
    </EncryptedData>
</connectionStrings>
```

Con esto ya tendríamos cifrada nuestra cadena de conexión y no tendríamos que realizar ninguna operación más, puesto que automáticamente .NET se encargaría de descifrarla para realizar la conexión y consulta de los datos.

Por último cabe mencionar que también podríamos descifrar nuestra cadena de conexión y dejarla tal y como estaba al principio ejecutando el comando:

``` none
aspnet_regiis.exe -pdf "connectionStrings" "unidad:\ruta\al\proyecto"
```
