---
layout: post
comments: false
title: Valores autoincrementables en Oracle
---

Si habitualmente sueles trabajar con bases de datos MySQL, pero en un proyecto determinado te dicen que tienes que usar Oracle, uno de los primeros problemas que te surge es como hacer que las claves primarias de tus tablas tenga un valor autoincrementable. Oracle no posee la propiedad de columnas autoincrementables, la solución que nos proporciona para conseguir este resultado son las secuencias.

Las secuencias proporcionan una lista consecutiva de números, de forma que cada vez que solicitemos un número a la secuencia nos devolverá su número actual y posteriormente incrementará su contador para proporcionar un número distinto la próxima vez que se le solicite.

<!--more-->

Para crear una secuencia basta con ejecutar una sentencia como la siguiente:

``` none
CREATE SEQUENCE Secuencia_Ejemplo START WITH 1 MAXVALUE 99999999 NOCYCLE;
```

Con esta sentencia estamos indicando que se va a crear una secuencia que se llamara *Secuencia_Ejemplo* comenzará por *1* y tendrá como valor máximo *99999999*. También indicamos que la secuencia no sea cíclica *NOCYCLE* para que una vez que llegue al final no vuelva a comenzar por 1.

Una vez que tenemos creada la secuencia, el siguiente paso es utilizarla a la hora de insertar datos en una tabla. La forma más cómoda  es mediante la creación de un trigger que se dispare cada vez que se inserte un nuevo dato y obtenga el valor de la secuencia. Un posible trigger, teniendo en cuenta que nuestra tabla tiene una columna llamada *id* sería el siguiente:

``` none
CREATE OR REPLACE TRIGGER insert_ejemplo BEFORE INSERT ON tabla_ejemplo FOR EACH ROW
BEGIN
    SELECT  Secuencia_Ejemplo .NEXTVAL
        INTO :NEW.id
    FROM dual;
END;
```

Este trigger se ejecutara para cada fila antes de que se inserte en la base de datos y obtendrá el siguiente valor de la *Secuencia_Ejemplo* que hemos creado antes con la llamada a **NEXTVAL**. Una vez obtenido, lo almacenara en la columna *id* de la nueva fila que se va a introducir *:NEW* y finalmente hará la inserción en la base de datos. La tabla *dual* a la que se hace referencia en el from, es una tabla especial de Oracle que sirve para usarla cuando necesitamos consultar valores que no depende de una tabla como puede ser una operación matemática, un sysdate ... Como en este caso no necesitamos ninguna tabla ya que estamos consultado una secuencia, pero la sentencia SQL necesita una clausura from utilizamos esta tabla para completar la sentencia.

Con esto ya tendríamos una columna autoincrementable en nuestra tabla de Oracle y podríamos trabajar igual que lo hacemos con MySQL. También existe otra forma para trabajar con las secuencias, esta forma sería llamar a la secuencia cada vez que se realiza un insert en la tabla.

``` none
INSERT INTO tabla_ejemplo (id, nombre, ... ) 
    VALUES ( Secuencia_Ejemplo.NEXTVAL, ''Pablo'', ...)
```

Personalmente esta forma me parece más engorrosa, ya que con el trigger de forma automática se genera el valor de la columna y no hay que estar indicándolo en cada insert.