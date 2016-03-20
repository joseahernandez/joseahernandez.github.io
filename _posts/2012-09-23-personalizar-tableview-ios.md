---
layout: post
comments: false
title: Personalizar TableView en iOS
---

El control TableView en iOS es uno de los controles más utilizados por las aplicaciones, esto se debe a la facilidad que proporciona para usarlo y al alto grado de personalización al que lo podemos someter. En la entrada de hoy vamos a ver como podemos personalizar un TableView para que muestre las celdas con el diseño que nos interese, en este ejemplo el resultado final será como el que se ve en la siguiente imagen.

![UITableView Personalizado](/uploads/posts/images/UITableView-personalized.png)

Como la finalidad de la entrada es mostrar como personalizar el TableView, los datos que se muestran se han generado en un bucle y en todos ellos se carga la misma imagen como veremos más adelante. En una aplicación normal, estos datos los obtendremos de una base de datos, de un servicio web ... 

Para comenzar crearemos un nuevo proyecto del tipo *Single View Application*. Lo primero que vamos a hacer es personalizar el TableViewCell para adaptarlo al formato que necesitemos, para ello añadimos un nuevo fichero de tipo *objective_c class* al que llamaremos **FilmsTableViewCell**. Haremos que herede de *UIViewController* y marcaremos la opción de crear el fichero XIB. A continuación, abrimos el fichero *FilmsTableViewCell.h*, modificamos la clase de la que hereda a *UITableViewCell* y creamos las siguientes propiedades:

<!--more-->

``` objective_c
@interface FilmsTableViewCell : UITableViewCell 

@property(nonatomic, strong)IBOutlet UILabel* title;
@property(nonatomic, strong)IBOutlet UILabel* director;
@property(nonatomic, strong)IBOutlet UILabel* rating;
@property(nonatomic, strong)IBOutlet UIImageView* cover;

@end
```

Las propiedades que hemos añadido las enlazaremos más adelante con los objetos del fichero XIB para poder indicar el titulo, el director, la valoración y la portada de cada una de las películas. Por otra parte, en el fichero *FilmsTableViewCell.m* borraremos todo su contenido y dejaremos lo siguiente:

``` objective_c
@implementation FilmsTableViewCell  

@synthesize title;
@synthesize director;
@synthesize rating;
@synthesize cover;

@end
```

Ahora es el turno de ponernos a trabajar con el Interfaz Builder y crear el diseño para la celda. Abrimos el fichero *CharacterSelectTableViewCell.xib*, eliminamos la vista actual en el árbol de herencia y seguidamente arrastramos un **UITableViewCell** desde la librería de objetos al lienzo:

![UITableViewCell](/uploads/posts/images/UITableViewCell.png)

A continuación, seleccionamos el UITableViewCell que acabamos de poner en el lienzo y en el **Identity Inspector** indicamos que la clase que va a utilizar es **FilmsTableViewCell**.

![Identity Inspector](/uploads/posts/images/Identity-Inspector.png)

Después vamos al **Attributes Inspector** e indicamos que el **Identifier** de la celda es **FilmCell**. Este identificador lo utilizaremos más adelante para indicar que queremos crear celdas de este tipo.

![Attribute Inspector](/uploads/posts/images/Attribute-Inspector.png)
 
El siguiente paso es indicar que clase se va a encargar de manejar las celdas, para ello seleccionamos el *File''s Owner* y en el **Identity Inspector** indicamos que la clase manejadora es **ViewController**. Como al principio hemos indicado que el proyecto será de tipo Single View Application, por defecto ya tendremos creada la clase **ViewController** que utilizamos aquí.

![Identity Inspector](/uploads/posts/images/Identity-Inspector-2.png)

Vamos ahora a crear la interfaz de la celda, abrimos el fichero *FilmsTableViewCell.xib* y arrastramos a la celda tres controles de tipo UILabel y uno de tipo UIImageView. Los ubicamos como queramos dentro de la celda, yo los he colocado de la siguiente forma:

![TableViewCell](/uploads/posts/images/TableViewCell.png)

Ahora es el turno de realizar las conexiones de los controles con las propiedades que hemos creado anteriormente. En el ejemplo los enlaces que he creado han sido:

* title al UILabel de la parte superior
* director al UILabel inferior
* rating al UILabel de la derecha
* cover al UIImageView

![TableViewCel Connections](/uploads/posts/images/TableViewCel-Connections.png)

Con la celda ya terminada vamos ahora a crear el modelo de datos de la aplicación. El modelo de datos únicamente contendrá una clase que almacenará la información de las películas. Crearemos un nuevo fichero de tipo *objective_c class*, que herede de NSObject y cuyo nombre será **Film**. Abrimos el fichero *Film.h* y declaramos las siguientes propiedades:

``` objective_c
@interface Film : NSObject

@property(strong, nonatomic) NSString* title;
@property(strong, nonatomic) NSString* director;
@property(strong, nonatomic) NSString* rating;
@property(strong, nonatomic) UIImage* cover;

@end
```

Seguidamente abrimos *Film.m* y hacemos el synthesize de las propiedades:

``` objective_c
@implementation Film

@synthesize title;
@synthesize director;
@synthesize rating;
@synthesize cover;

@end
```

A continuación vamos al fichero *ViewController.h* y hacemos que herede de la clase *UITableViewController*. Además le añadimos una propiedad para almacenar en un NSArray todas las componentes que mostrará nuestro UITableView:

``` objective_c
@interface ViewController : UITableViewController

@property(strong, nonatomic) NSArray* items;

@end
```

Después pasamos al fichero *ViewController.m* donde implementaremos los métodos del **UITableViewDataSource** necesarios para poder trabajar con un UITableView y haremos el synthesize de la propiedad que hemos declarado antes:

``` objective_c
#import "ViewController.h"
#import "FilmsTableViewCell.h"
#import "Film.h"

@implementation ViewController

@synthesize items;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:
    (NSInteger)section
{
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
    cellForRowAtIndexPath: (NSIndexPath *)indexPath
{

    static NSString* CellIdentifier = @"FilmCell";

    FilmsTableViewCell* cell = (FilmsTableViewCell*)[tableView
        dequeueReusableCellWithIdentifier:CellIdentifier];  

    if( !cell )
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FilmsTableViewCell"
            owner:nil options:nil] objectAtIndex:0];
    }

    Film* film = [items objectAtIndex:indexPath.row];

    cell.title.text = film.title;
    cell.director.text = film.director;
    cell.rating.text = film.rating;
    cell.cover.image = film.cover;
    
    return cell;
}

@end

```

Con el método **(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView** indicamos que nuestro UITableView únicamente tendrá una sección. El método **(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section** será el encargado de indicar cuantas componentes tenemos para mostrar, es decir la cantidad de elementos que tenemos en nuestro array items. Finalmente el método **(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath** se encargará de obtener una celda libre, en caso de no obtenerla creará una nueva  cargándola del nib que hemos creado al principio y finalmente recuperará la película correspondiente del array ítems y configurará la celda.

Pasamos ahora al fichero *ViewController.xib* y eliminamos el objeto view. Ahora arrastramos de la biblioteca un **UITableView**. A continuación seleccionamos el *File''s Owner* e indicamos que su clase es **ViewController**. Después de esto hacemos Ctrl + click encima del *Files''s Owner* y conectamos la propiedad **view** con el UITableView que acabamos de poner en el lienzo.

Con esto tendremos nuestro ejemplo finalizado, ahora vamos al fichero *AppDelegate.m* donde crearemos algunos elementos de tipo **Film**  para probar la aplicación. Modificaremos el método **didFinishLaunchingWithOptions** dejándolo de la siguiente forma:

``` objective_c
- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] 
        bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:
        @"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
      
    NSMutableArray* films = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 20; i++)
    {
        Film* f = [[Film alloc] init];
        f.title = [[NSString alloc] initWithFormat: @"Película %d", i];
        f.director = [[NSString alloc] initWithFormat: @"Director %d", i];
        f.rating = [[NSString alloc] initWithFormat:@"%d", arc4random() %5];
        f.cover = [UIImage imageNamed:@"comunidad-anillo"];
                   
        [films addObject:f];
    }
     
    self.viewController.items = films;
    
    [self.window makeKeyAndVisible];
    return YES;
}
```

Ahora podemos probar nuestra aplicación y ver como obtenemos el resultado esperado.