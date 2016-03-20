---
layout: post
comments: false
title: Conexión a base de datos con Node.js
---

Dando un paso más en la serie de tutoriales sobre Node.js ahora nos toca ver como podemos conectarnos a una base de datos para poder trabajar con la persistencia de datos. Para realizar este ejemplo vamos a trabajar con una base de datos MySQL y utilizaremos el paquete [mysql](https://npmjs.org/package/mysql). Comenzaremos creando una carpeta donde almacenaremos nuestro proyecto y abriendo un terminal lo primero que haremos será instalar los paquetes *express*, *jade* y el anteriormente mencionado *mysql*

``` none
> npm install express
> npm install jade
> npm install mysql
```

Como se puede observar vamos a ir volviendo a utilizar todo lo que hemos estado viendo hasta ahora en esta serie de tutoriales para ver como podemos hacer que funcione todo conjuntamente. A continuación vamos a crear una base de datos sobre la cual trabajaremos, para hacerlo sencillo la base de datos tendrá únicamente una tabla llamada *universidades* que contendrá un identificador, un nombre y la ciudad a la que pertenece una universidad. Podéis descargar un script con la estructura y algunos datos desde [aquí](/uploads/posts/samples/universidades.sql).

A continuación vamos a crear un fichero en nuestro directorio de trabajo al que llamaremos **server.js** y para comenzar escribiremos lo siguiente en él:

<!--more-->

``` javascript
var express = require('express');
var mysql = require('mysql');
 
var app = express();
 
app.configure(function() {
    app.set('views', __dirname + '/views');
    app.set('view options', { layout: false });
    app.use(express.bodyParser());
    app.use(express.static(__dirname + '/public'));
});

var client = mysql.createClient({
    host: 'localhost',
    user: 'user',
    password: 'pass',
});

client.database = 'universidades';
```

En este fichero comenzamos importando dos paquetes de los antes mencionados *express* y *mysql* a continuación inicializamos y configuramos *express*. El siguiente paso es configurar *mysql* para ello creamos una variable a la que llamamos **client** que será la encargada de realizar todo el trabajo contra la base de datos. Esta variable la inicializamos con el método **mysql.createClient()** al cual le pasamos los parámetros del host donde está alojada la base de datos, el usuario de la base de datos y la contraseña. Una vez realizado esto, el siguiente paso es indicar con que base de datos se va a trabajar, para ello le indicamos a la variable **client** el nombre de la base de datos con su propiedad **database**.

Con esto realizado ya tenemos preparada la conexión con la base de datos, el siguiente paso va a ser realizar una consulta, para al final del fichero **server.js** añadimos lo siguiente:

``` javascript
app.get('/', function(req, res) {
    client.query('SELECT id, nombre, ciudad FROM universidades',
        function selectCb(err, results, fields) {
            if (err) {
                throw err;
            }

            res.render('index.jade', { universidades: results });
        }
    );
});
```

Aquí tenemos el método que se ejecutará cuando se solicita la raíz de nuestro sitio. En este método y con ayuda del objeto **client** que hemos creado anteriormente realizamos una consulta a la base de datos con el método **query()**, este método puede tener dos o tres argumentos. En el caso del ejemplo tenemos dos argumentos, en los cuales el primero de ellos es la sentencia SQL que vamos a ejecutar y el segundo es una función callback que se ejecutará cuando finalice la consulta.

La función callback recibe tres argumentos, el primero de ellos es si se ha producido algún error en la consulta, el segundo son los valores devueltos por la consulta y el tercero son los campos de la tabla que han sido devueltos. En el ejemplo se comprueba que no exista ningún error y a continuación se renderiza una plantilla jade pasándole como parámetros las universidades devueltas por la consulta.

Como hemos mencionado antes, el método **query()** podía recibir también tres parámetros, en este caso el primero parámetro seguirá siendo la consulta SQL a ejecutar, el segundo parámetros será un array donde pondremos el valor de los parámetros que hayamos introducido en la sentencia SQL y el tercer parámetros de la función query de nuevo será la función de callback. De esta forma podemos escapar los valores de la sentencia SQL con facilidad como podemos ver en este ejemplo:

``` javascript
var universidadId = new Array('1');

client.query('SELECT id, nombre, ciudad FROM universidades WHERE id = ?', 
    universidadId,
    function selectCb(err, results, fields) {
        ...
    }
);
```

Con esto finalizado, el siguiente paso es crear las vistas para mostrar los datos que se han recuperado de la base de datos, para ello creamos una nueva carpeta a la que llamaremos *views* y dentro de esta carpeta crearemos un documento al que llamaremos **layout.jade**. Este será el layout de toda nuestra aplicación y su contenido será el siguiente:

``` coffeescript
doctype html
html
    head
        link(rel='stylesheet', href='/css/style.css')
        title Universidades de España
    body
        header
            h1 Universidades de España         
        
        block content
```

A continuación crearemos la vista que se encargará de mostrar la lista de universidades. De nuevo en la carpeta *views* crearemos un nuevo documento al que llamaremos **index.jade**. Su contenido será el siguiente:

``` coffeescript
extends layout
     
block content
    section
        form(action='/nueva', method='post')
            label Nombre:
            input(name='nombre')
            label Ciudad:
            input(name='ciudad')
            input(type='submit', value='Guardar')

    section
        if universidades.length == 0
            p No existen universidades en la base de datos
        else
            table
                tr
                    th Universidad
                    th Ciudad
                    th
                for universidad in universidades
                    tr
                        td=universidad.nombre
                        td=universidad.ciudad
                        td
                            a(href='/editar/#{universidad.id}')
                                img(src='/img/edit.png', alt='Editar')
                            a(href='/borrar/#{universidad.id}')
                                img(src='/img/delete.png', alt="Borrar')
```

Si te fijas en la plantilla que acabamos de crear, te darás cuenta que hemos incluido tres urls nuevas que tendremos que implementar a continuación. La primera de ellas es **/nueva** y se ejecutará cuando se envíe el formulario para insertar una nueva universidad, así que volvemos al fichero **server.js** y al final del documento añadimos lo siguiente:

``` javascript
app.post('/nueva', function(req, res) {
    client.query('INSERT INTO universidades (nombre, ciudad) VALUES (?, ?)', 
        [req.body.nombre, req.body.ciudad],
        function() {
            res.redirect('/');
        }
    );
});
```

Como vemos de nuevo usamos la función **query** para ejecutar la sentencia SQL y le pasamos los dos valores como parámetros en un array, finalmente una vez que se ha ejecutado la consulta redireccionamos a la ruta / para que se vuelva a mostrar todas las universidades disponibles.

La siguiente ruta que se muestra en la plantilla anterior es **/editar/#{universidad.id}** a la hora de renderizarse la variable universidad.id se sustituirá por el valor del id así que vamos  a crear el método para manejar esta ruta.

``` javascript
app.get('/editar/:id', function(req, res) {
    client.query('SELECT id, nombre, ciudad FROM universidades WHERE id = ?', 
        [req.params.id],
        function selectCb(err, results, fields) {
            res.render('editar.jade', { universidad: results[0] });
        }
  );
});
```

En esta ocasión realizamos la consulta y renderizamos la plantilla **editar.jade** que aun no hemos creado, así que a continuación la creamos con el siguiente contenido:

``` coffeescript
extends layout
     
block content
    section
        form(action='/actualizar', method='post')
            input(type='hidden', name='id', value=universidad.id)
            label Nombre:
            input(name='nombre', value=universidad.nombre)
            label Ciudad:
            input(name='ciudad', value=universidad.ciudad)
            input(type='submit', value='Actualizar')
```

En esta nueva plantilla hemos añadido una url nueva **/actualizar** así que tenemos que añadirla también con su función a nuestro fichero **server.js**

``` javascript
app.post('/actualizar', function(req, res) {
    client.query('UPDATE universidades SET nombre = ?, ciudad = ? WHERE id = ?',
        [req.body.nombre, req.body.ciudad, req.body.id],
        function() {
            res.redirect('/');
        }
    );
});
```

De nuevo en esta función ejecutamos la sentencia SQL, y a continuación redireccionamos la pagina raíz para que se muestre el cambio realizado en la base de datos.

Para finalizar nos queda ver como borrar un elemento de la base de datos, si recordamos la plantilla **index.jade** creamos una url para realizar esta tarea, ahora implementaremos esa ruta en nuestro fichero **server.js**

``` javascript
app.get('/borrar/:id', function(req, res) {
    client.query('DELETE FROM universidades WHERE id = ?', 
        [req.params.id],
        function() {
            res.redirect('/');
        }
    );
});
```

De nuevo de forma sencilla ejecutamos la sentencia de borrado y volvemos a redireccionar a la página inicial para mostrar los cambios realizados. Para finalizar escribimos al final del fichero el puerto donde queremos que escuche nuestra aplicación y ya la tenemos lista para probarla:

``` javascript
app.listen(3333);
```

Como hemos podido apreciar durante todos los ejemplos, ha sido muy sencillo trabajar en Node.js contra una base de datos. A partir de aquí si queréis más información sobre el paquete *mysql* de node, podéis darle un vistazo a su [repositorio en Github](https://github.com/felixge/node-mysql) y si este paquete no os gusto o necesitáis más funcionalidad siempre se pueden buscar nuevos paquetes en el [repositorio de paquetes para node](https://npmjs.org/). Dejo el ejemplo realizado [aquí](/uploads/posts/samples/Conectar-base-datos-node.rar) por si queréis descargarlo.

Entradas relacionadas:

* [Introducción a Node.js](/2012/05/27/introduccion-nodejs.html)
* [Gestión de rutas en Node.js](/2012/06/16/gestion-de-rutas-nodejs.html)
* [Plantillas en Node.js](/2012/07/12/plantillas-nodejs.html)