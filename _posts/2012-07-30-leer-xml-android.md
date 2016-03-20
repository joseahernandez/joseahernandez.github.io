---
layout: post
comments: false
title: Leer XML en Android
---

Leer ficheros XML en Android es una tarea con la que posiblemente nos enfrentemos bastante a menudo, ya sea porque creamos nosotros mismos esos ficheros para almacenar datos, porque lo obtenemos de un servicio web o de cualquier otra forma. Android nos proporciona tres formas para poder enfrentarnos a esta tarea: XMLPull, SAX y DOM. En esta entrada vamos a ver como podemos leer un fichero XML con DOM. Para comenzar lo primero que necesitamos es un fichero XML así que aquí pongo un ejemplo del fichero que vamos a leer:

``` xml
<libros>
    <libro>
        <titulo>La última cripta</titulo>
        <autor>Fernando Gamboa González</autor>
        <precio>0,98</precio>
    </libro>
    <libro>
        <titulo>Cincuenta sombras de Grey</titulo>
        <autor>E.L. James</autor>
        <precio>9,49</precio>
    </libro>
    <libro>
        <titulo>Cincuenta sombras más oscuras</titulo>
        <autor>E.L. James</autor>
        <precio>9,49</precio>
    </libro>
    <libro>
        <titulo>London</titulo>
        <autor>Rutherfurd Edward</autor>
        <precio>4,74</precio>
    </libro>
    <libro>
        <titulo>Cincuenta sombras liberadas</titulo>
        <autor>E.L. James</autor>
        <precio>9,49</precio>
    </libro>
    <libro>
        <titulo>Muerte sin resurección</titulo>
        <autor>Roberto Martínez Guzmán</autor>
        <precio>0,98</precio>
    </libro>
    <libro>
        <titulo>Defender a Jacob</titulo>
        <autor>Willam Landay</autor>
        <precio>9,02</precio>
    </libro>
    <libro>
        <titulo>Nunca fuimos a Katmandú</titulo>
        <autor>Lola Mariné</autor>
        <precio>0,98</precio>
    </libro>
    <libro>
        <titulo>La noche más oscura</titulo>
        <autor>Gena Showalter</autor>
        <precio>5,51</precio>
    </libro>
    <libro>
        <titulo>El asesino de la Vía Láctea</titulo>
        <autor>Gabriel Martínez</autor>
        <precio>0,89</precio>
    </libro>
</libros>
```

Este fichero contiene 10 libros de los cuales tenemos su título, su autor y su precio. Supongamos que este fichero lo tenemos en la carpeta *raw* de nuestro proyecto y su nombre es *libros.xml*. Como ya sabemos cual va a ser la información con la que vamos a trabajar, nos creamos una clase a la que llamaremos **Libro** para almacenar los datos de cada libro.

<!--more-->
   
``` java
class Libro {

    private String titulo;
    private String autor;
    private double precio;

    public Libro() {
        this.titulo = "";
        this.autor = "";
        this.precio = 0;
    }

    public Libro(String titulo, String autor, double precio) {
        this.titulo = titulo;
        this.autor = autor;
        this.precio = precio;
    }

    public String getTitulo() {
        return titulo;
    }
    
    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }
    
    public String getAutor() {
        return autor;
    }
    
    public void setAutor(String autor) {
        this.autor = autor;
    }
    
    public double getPrecio() {
        return precio;
    }
    
    public void setPrecio(double precio) {
        this.precio = precio;
    }
}
```

Una vez que tenemos esta clase, vamos a crearnos un método que lea todos los libros de este XML y nos devuelva un vector con todos los libros leídos.

``` java
public Vector<Libro> leerLibros() {
    ArrayList<Libro> libros = new ArrayList<Libro>();

    try {
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
        DocumentBuilder builder = factory.newDocumentBuilder();
        // Parseamos el documento obteniendolo de los recursos y lo almacenamos 
        // en un objeto Document
        Document doc = builder.parse(getResources()
            .openRawResource(R.raw.libros));
    
        // Obtenemos el elemento raiz del documento, libros 
        Element raiz = doc.getDocumentElement();
    
        // Obtenemos todos los elementos llamados libro, que cuelgan 
        // de la raiz
        NodeList items = raiz.getElementsByTagName("libro");
    
        // Recorremos todos los elementos obtenidos
        for( int i = 0; i < items.getLength(); i++ ) {
            Node nodoLibro = items.item(i);
            Libro libro = new Libro();

            // Recorremos todos los hijos que tenga el nodo libro
            for(int j = 0; j < nodoLibro.getChildNodes().getLength(); j++ ) {
                Node nodoActual = nodoLibro.getChildNodes().item(j);

                // Compruebo si es un elemento
                if( nodoActual.getNodeType() == Node.ELEMENT_NODE ) {
                    if( nodoActual.getNodeName().equalsIgnoreCase("autor") )
                        libro.setAutor(nodoActual.getChildNodes().item(0)
                            .getNodeValue());
                    else if( nodoActual.getNodeName()
                        .equalsIgnoreCase("titulo") )
                        libro.setTitulo(nodoActual.getChildNodes().item(0)
                            .getNodeValue());
                    else if( nodoActual.getNodeName()
                        .equalsIgnoreCase("precio") ) {
                        // Cambio las , por . para convertirlo a double
                        String precio = nodoActual.getChildNodes().item(0)
                            .getNodeValue().replace(',', '.');
                        libro.setPrecio(Double.parseDouble(precio));
                    }
                }
            }
            libros.add(libro);
        }
    }
}
```

Simplemente con este método conseguiríamos tener todo nuestro fichero XML parseado y en un vector de elementos Libro. Si el documento en vez de estar en nuestro proyecto lo recuperáramos de un servicio web como hemos mencionado antes, la forma de parsearlo sería la misma. Lo único que tendríamos que modificar es la forma de recuperar el fichero. En vez de leerlo de los recursos, obtendríamos una conexión al servidor para realizar la petición de la siguiente forma:

``` java
DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
DocumentBuilder builder = factory.newDocumentBuilder();

// Obtenemos el fichero de internet
HttpGet httpGet = new HttpGet("http://url_a_un_xml.xml");
HttpClient httpCliente = new DefaultHttpClient();
HttpResponse response = (HttpResponse)httpCliente.execute(httpGet);
HttpEntity entity = response.getEntity();
BufferedHttpEntity buffer = new BufferedHttpEntity(entity);
InputStream is = buffer.getContent();

// Parseamos el fichero y lo almacenamos en un objeto Document
Document doc = builder.parse(is);

// ...
```

Como se puede ver no nos ha costado mucho obtener el array con todos los libros contenidos en nuestro XML.