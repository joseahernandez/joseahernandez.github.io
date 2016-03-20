---
layout: post
comments: false
title: Parsear XML en iOS con NSXMLParser
---

Si el otro día veíamos como parsear un documento XML en Android, hoy es el turno de ver como realizar la misma tarea en iOS. Para parsear un XML, el SDK de iOS nos proporciona la clase [NSXMLParser](https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSXMLParser_Class/Reference/Reference.html) que nos facilita la tarea. Esta clase se encarga de notificarle a su delegate cada vez que encuentra una etiqueta de apertura, el contenido de una etiqueta o una etiqueta de cierre mediante los métodos [parser: didStartElement: namespaceURI: qualifiedName: attributes:](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSXMLParserDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/NSXMLParserDelegate/parser:didStartElement:namespaceURI:qualifiedName:attributes:), [parser: foundCharacters:](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSXMLParserDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/NSXMLParserDelegate/parser:foundCharacters:) y [parser: didEndElement: namespaceURI: qualifiedName:](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/NSXMLParserDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/NSXMLParserDelegate/parser:didEndElement:namespaceURI:qualifiedName:) respectivamente.

Una desventaja que cuenta NSXMLParser es que no tiene memoria y no recuerda lo que ha parseado anteriormente. Pongamos un ejemplo para explicar lo que quiere decir esto, si tenemos el siguiente XML:

``` xml
<libro>
  <titulo>La última cripta</titulo>
  <autor>Fernando Gamboa González</autor>
  <precio>0,98</precio>
</libro>
<libro>
    <titulo>Muerte sin resurección</titulo>
    <autor>Roberto Martínez Guzmán</autor>
    <precio>0,98</precio>
  </libro>
```

Cuando se lea la etiqueta *\<libro\>* se ejecutará el método *parser: didStartElement: namespaceURI: qualifiedName: attributes:*, a continuación se encuentra la etiqueta *\<titulo\>* y se vuelve a ejecutar el método parser: didStartElement: namespaceURI: qualifiedName: attributes:. El problema que podríamos tener aquí es que no podemos saber cual de las dos posibles etiquetas que aparecen en el XML es a la que se refiere. Pero si continuamos, lo siguiente que se encuentra el parser es la cadena de texto *La última cripta*, por lo tanto se ejecutaría el método parser: foundCharacters: y aquí tendríamos otro problema porque no podríamos diferenciar si esa cadena pertenece a la etiqueta *\<titulo\>* o a cualquier otra que contenga carácteres. Cuando lleguemos a la etiqueta *\<autor\>* y se encuentre su cadena de texto, otra vez se ejecutaría el método parser: foundCharacters: y de nuevo no podríamos saber esa cadena a que etiqueta pertenece.

<!--more-->

Una posible solución sería llevar unos contadores para saber cuantos libros se han parseado, cuantas etiquetas de cada libro se han leído y según el número, diferenciar si se trata del título, el autor o el precio. Pero esta solución es bastante sucia y engorrosa. Para hacer esto más elegante, vamos a crearnos una clase **Libro** que almacenará los datos y haremos que esa clase cumpla el delegate [NSXMLParserDelegate](http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSXMLParserDelegate_Protocol/Reference/Reference.html), de forma que pueda leer sus propios datos. El fichero *Libro.h* será así:

``` objective_c
@interface Libro : NSObject <NSXMLParserDelegate>
{
    NSMutableString* auxString;
}

@property(nonatomic, strong) NSString* titulo;
@property(nonatomic, strong) NSString* autor;
@property(nonatomic) double precio;

@property(nonatomic, weak) id<NSXMLParserDelegate> parserPadre;

@end
```

La clase **Libro** contiene un NSMutableString que nos servirá para ir almacenando las cadenas de texto que leamos del XML y posteriormente almacenarla en la propiedad adecuada. A continuación vemos las *properties* con cada uno de los elementos que contiene un libro. Finalmente tenemos otra *property* que se encargará de almacenar quien ha sido la clase que estaba parseando el XML antes de delegar esta función en nuestra clase Libro (si esto no queda muy claro, más adelante creo que se entenderá mejor).

En cuanto al fichero .cpp será así:

``` objective_c
@implementation Libro
@synthesize titulo, autor;
@synthesize precio;
@synthesize parserPadre;

- (void)parser:(NSXMLParser *)parser 
    didStartElement:(NSString *)elementName 
    namespaceURI:(NSString *)namespaceURI 
    qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:@"titulo"] )
    {
        auxString = [[NSMutableString alloc] init];
        [self setTitulo:auxString];
    }
    else if( [elementName isEqualToString:@"autor"] )
    {
        auxString = [[NSMutableString alloc] init];
        [self setAutor:auxString];
    }
    else if( [elementName isEqualToString:@"precio"])
    {
        auxString = [[NSMutableString alloc] init];
        [self setPrecio:[auxString doubleValue]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [auxString appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
    namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    auxString = nil;
    
    if( [elementName isEqualToString:@"libro"] )
        [parser setDelegate:parserPadre];
}

@end
``` 

Lo primero que hacemos es el *synthesize* de todas las *properties* que hemos declarado en el fichero de cabecera y a continuación definimos los métodos del protocolo [NSXMLParserDelegate](http://developer.apple.com/library/ios/#documentation/cocoa/reference/NSXMLParserDelegate_Protocol/Reference/Reference.html) que hemos mencionado antes.

El método *-parser: didStartElement: namespaceURI: qualifiedName: attributes:* se encarga de obtener el tipo de etiqueta que se esta parseando actualmente, a continuación inicializa la variable **auxString** y se la asigna al atributo adecuado de la clase. A continuación el método *-parser: foundCharacters:* se encarga de leer el valor de la etiqueta y lo almacena en la variable **auxString**. Como anteriormente hemos asignado la variable **auxString** a la property adecuada según el tipo de etiqueta que estábamos leyendo, también estamos poniendo el valor en ese atributo de la clase. Finalmente el método *-parser: didEndElement: namespaceURI: qualifiedName:* se encarga de volver a asignar la clase que anteriormente estaba parseando el documento si encuentra la etiqueta final de libro.

Una vez tenemos la clase Libro implementada, podemos obtener el documento XML, comenzar a parsearlo y a crear los elementos de tipo Libro. En este ejemplo, vamos a realizar toda esta operación en el método *-application: didFinishLaunchingWithOptions:* de la clase *AppDelegate*. Para ello en el fichero **AppDelegate.h** dejamos el siguiente código:

``` objective_c
@class ViewController;
@class Libro;

@interface AppDelegate : UIResponder <UIApplicationDelegate, 
    NSXMLParserDelegate>
{
    Libro* auxLibro;
    NSXMLParser* parserData;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) NSMutableArray* libros;

@end
```

Hemos añadido a la clase un atributo de tipo Libro llamado *auxLibro* que utilizaremos para ir creando los libros según los vayamos leyendo del XML, también tenemos un atributo del tipo NSXMLParser que se encargará de parsear el documento y finalmente hemos añadido una property de tipo NSMutablaArray para ir almacenando todos los libros que leamos del XML.

En el código del método *-application: didFinishLaunchingWithOptions:* añadiremos las siguiente líneas al final:

``` objective_c
// Ruta al fichero XML
NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"libros" 
    ofType:@"xml"];
NSData *data = [NSData dataWithContentsOfFile:xmlPath];
    
libros = [[NSMutableArray alloc] init];
    
parserData = [[NSXMLParser alloc] initWithData:data];
[parserData setDelegate:self];
[parserData parse];

[self.window makeKeyAndVisible];
return YES;
```

En este código obtenemos el path donde se encuentra el fichero XML y lo leemos y almacenamos en la variable **data**. Seguidamente inicializamos el NSMutableArray para almacenar los libros y para finalizar creamos el objeto de tipo NSXMLParser, le indicamos que el delegate es esta clase y comentamos a parsear el documento.

Para finalizar tenemos que implementar en esta clase también el método *-parser: didStartElement: namespaceURI: qualifiedName: attributes:*:

``` objective_c
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
    namespaceURI:(NSString *)namespaceURI 
    qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict
{
    if( [elementName isEqualToString:@"libro"] )
    {
        auxLibro = [[Libro alloc] init];
        auxLibro.parserPadre = self;
        [parserData setDelegate:auxLibro];
        
        [libros addObject:auxLibro];
    }      
}
```

Este método se encarga cada vez que se encuentra la etiqueta libro, crear en la variable **auxLibro** un nuevo objeto de tipo libro, asignarle la clase actual como la clase que se esta encargando de parsear el documento, cambiar el delegate del parse actual a la nueva clase creada Libro y añadir el nuevo objeto al NSMutableArray de libros.

Una vez realizado esto, cada vez que se encuentre una etiqueta libro se cambiará la clase que realiza el parser a la clase Libro que como hemos visto anteriormente se encargará de rellenar sus datos.

Con esto hemos terminado de realizar el parseado del documento XML, al finalizar tendremos en el NSMutableArray libro todos los libros que aparecen en el XML disponibles para poder trabajar con ellos.

Para finalizar quiero comentar que esta forma de parsear un documento XML la he aprendido del libro [IOS Programming: The Big Nerd Ranch Guide](http://www.bignerdranch.com/book/ios_programming_the_big_nerd_ranch_guide_rd_edition_), libro que recomiendo leer a todos aquellos que quieran aprender la programación de iOS.