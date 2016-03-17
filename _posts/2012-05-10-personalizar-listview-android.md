---
layout: post
comments: false
title: Personalizar ListView en Android
---

Llevo un tiempo trabajando con Android y aprendiendo a desarrollar software para esta plataforma, así que creo que ya es momento de comenzar a realizar algunas entradas sobre Android. Para comenzar vamos a ver como personalizar un ListView.

Android nos proporciona por defecto un par de estilos para los items que aparecerán dentro de un ListView. Pero si queremos personalizarlo más, no tenemos otra alternativa que programarlo nosotros mismos. Aunque pueda parecer una tarea compleja es bastante sencillo realizar esta personalización. Supongamos que queremos que los items sean como la siguiente imagen:

![Android ListView Item](/uploads/posts/images/android-item-in-listview.png)

<!--more-->

En ella podemos ver una imagen a la izquierda, un título en la parte central, un subtitulo con una fuente más pequeña en la parte inferior y de nuevo otra imagen en la parte de la derecha. El ejemplo que vamos a realizar es una lista de la compra, donde la imagen de la izquierda será una foto del producto, el título principal será el nombre del producto, el subtitulo será el tipo de producto y la imagen de la derecha será simplemente un icono.

Lo primero que vamos a crear es un layout para organizar la disposición de todos estos elementos en la pantalla, así que creamos un nuevo fichero xml en la carpeta layout al que llamaremos *list_item_layout.xml* y en el que pondremos el siguiente código:

{% highlight xml linenos %}
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="wrap_content" >

    <ImageView
        android:id="@+id/imagen"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentLeft="true"
        android:layout_centerInParent="true"/>
    
    <TextView
        android:id="@+id/nombre"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentTop="true"
        android:layout_centerHorizontal="true"
        android:text="Large Text"
        android:textAppearance="?android:attr/textAppearanceLarge" />

    <TextView
        android:id="@+id/tipo"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_below="@+id/nombre"
        android:layout_centerHorizontal="true"
        android:text="TextView" />

    <ImageView
        android:id="@+id/imageView1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentRight="true"
        android:layout_centerInParent="true"
        android:src="@drawable/next" />
   
</RelativeLayout>
{% endhighlight %}

Como se puede ver hemos utilizado un **RelativeLayout** para organizar la información, gracias a este layout organizamos el resto de los componentes ajustándolos con él para dar el formato tal y como nos interesa. Para ello utilizamos las propiedades **layout_alignParantLeft**, **layout_centerInParent**, **layout_alignParentTop**, **layout_centerHorizontal**, **layout_alignParentRight** y **layout_below**. Aunque la función de cada una de estas propiedades está bastante clara por su nombre vamos a explicar que es lo que realizan:

* **layout_alignParantLeft**, **layout_alignParentTop** y **layout_alignParentRight**: alinean el componente a la parte izquierda, arriba o derecha del componente padre que los contiene.
* **layout_centerInParent**: centra el componente respecto al padre.
* **layout_below**: coloca el componente debajo del componente cuyo id sea el que indicamos.

Una vez aclarado estas propiedades, dentro del layout tenemos dos **ImageView** y dos **TextView** que serán los encargados de contener toda la información que nos interesa. A todos estos componentes les asignamos las propiedades de layout que hemos mencionado antes para ajustarlos como queramos y nos proporcionen el aspecto que buscamos.

Una vez tenemos el layout vamos a definir el modelo de datos, para ello crearemos una clase llamada *ItemCompra.java* y cuyo contenido será el siguiente:

{% highlight java linenos %}
public class ItemCompra {
    protected long id;
    protected String rutaImagen;
    protected String nombre;
    protected String tipo;

    public ItemCompra() {
        this.nombre = "";
        this.tipo = "";
        this.rutaImagen = "";
    }

    public ItemCompra(long id, String nombre, String tipo) {
        this.id = id;
        this.nombre = nombre;
        this.tipo = tipo;
        this.rutaImagen = "";
    }

    public ItemCompra(long id, String nombre, String tipo, String rutaImagen) {
        this.id = id;
        this.nombre = nombre;
        this.tipo = tipo;
        this.rutaImagen = rutaImagen;
    }

    public long getId() {
        return id;
    }
    
    public void setId(long id) {
        this.id = id;
    }

    public String getRutaImagen() {
        return rutaImagen;
    }

    public void setRutaImagen(String rutaImagen) {
        this.rutaImagen = rutaImagen;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
  
    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
}
{% endhighlight %}

No creo que necesite explicación, simplemente es una clase que contendrá las variables necesarias para almacenar los elementos que más tarde queremos que aparezcan en el ListView. Estos elementos serán el identificador, el nombre, el tipo y la ruta de la imagen para poder mostrarla.

Después de esto nos toca personalizar el adapter. Como sabrás, para rellenar un ListView tenemos que pasarle un elemento de tipo **Adapter** con los datos queremos que contenga el ListView. Normalmente para un ListView simple se utiliza la clase **ArrayAdapter**, pero como nuestro ListView va a ser personalizado tenemos que crear nuestro propio adapter. Para ello simplemente tenemos que crear una clase derivada de **BaseAdapter** y sobrescribir los métodos que contiene esta clase abstracta. Creamos un fichero que llamaremos *ItemCompraAdapter.java* y le añadimos el siguiente contenido:

{% highlight java linenos %}
public class ItemCompraAdapter extends BaseAdapter {
    protected Activity activity;
    protected ArrayList<ItemCompra> items;

    public ItemCompraAdapter(Activity activity, ArrayList<ItemCompra> items) {
        this.activity = activity;
        this.items = items;
    }

    @Override
    public int getCount() {
        return items.size();
    }

    @Override
    public Object getItem(int position) {
        return items.get(position);
    }

    @Override
    public long getItemId(int position) {
        return items.get(position).getId();
    }

    @Override
    public View getView(int position, View contentView, ViewGroup parent) {
        View vi=contentView;

        if(contentView == null) {
            LayoutInflater inflater = (LayoutInflater) activity
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            vi = inflater.inflate(R.layout.list_item_layout, null);
        }
            
        ItemCompra item = items.get(position);
        
        ImageView image = (ImageView) vi.findViewById(R.id.imagen);
        int imageResource = activity.getResources()
            .getIdentifier(item.getRutaImagen(), null, 
                activity.getPackageName());
        image.setImageDrawable(activity.getResources().getDrawable(
            imageResource));
            
        TextView nombre = (TextView) vi.findViewById(R.id.nombre);
        nombre.setText(item.getNombre());
            
        TextView tipo = (TextView) vi.findViewById(R.id.tipo);
        tipo.setText(item.getTipo());
    
        return vi;
    }
}
{% endhighlight %}

Esta clase contiene dos atributos: **activity** e **items**. Ambos son pasados al constructor para inicializar el adapter. El atributo activity es necesario para poder generar el layout que hemos creado anteriormente para nuestros item en el ListView, mientras que el ArrayList de items contiene los elementos que se mostrarán. A continuación se sobrescriben los métodos de la clase abstracta, **getCount** tiene que devolver la cantidad de items que contiene el adapter, esa cantidad la obtenemos desde el ArrayList que tenemos. El método **getItem** tiene que devolver el item que se encuentra en la posición que se pasa como parámetro, de nuevo gracias al ArrayList podemos obtener el item correcto sin ningún tipo de problema. El método que nos queda, **getView**, se encarga de mostrar los items dentro del ListView. Este método es algo más complejo así que creo que merece la pena explicarlo un poco.

**getView** es llamado cada vez que hay que pintar un item del ListView en la pantalla del dispositivo. Lo que quiere decir que si tenemos 10 elementos en nuestro ListView pero en la pantalla solo se visualizan 5 elementos, al comenzar la aplicación se llamada a **getView** 5 veces para mostrar esos 5 elementos. Conforme realicemos scroll para recorrer el resto de elementos, se volverá a llamar para volver a pintar los elementos que se vean. Con esto en mente, lo primero que hacemos es asignar el segundo parámetro llamado **contentView** a una variable local para trabajar con el. El **contentView** es la vista del item, es decir, como se va a mostrar el item dentro del ListView. Si es null lo que tenemos que hacer es inicializarlo, para ello obtenemos el **LayoutInflater** llamando al método **activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE)**. El LayoutInflater se encarga de pasándole un recurso xml generar una vista para que podamos trabajar con ella, por lo tanto con el LayoutInflater llamaremos al método **inflate** indicándole el recurso para el que queremos generar la vista, en nuestro caso **R.layout.list_item_layout**. Una vez que la vista para el item está inicializada o la hemos recibido ya inicializada recuperamos el item que vamos a mostrar utilizando el primer parámetro que recibe el método **getView** y el ArrayList que tenemos con los items. A continuación vamos recuperando los componentes de la vista y rellenándolos con los datos adecuados. Comenzamos con la imagen del elementos, obtenemos el componente con ayuda del método **findViewById** a continuación obtenemos el identificador de la imagen a partir de los recursos de la aplicación, para ello usamos el método **getIdentifier** habiendo obtenido los recursos de la aplicación previamente con el método **activity.getResources**. **getIdentifier** necesita que le pasemos como primer parámetro la ruta donde se encuentra la imagen en los recursos y como último parámetro el nombre del paquete, el segundo parámetro lo podemos dejar a null. Después de esto le aplicamos la imagen al ImageView con el método **setImageDrawable**. Para obtener la imagen tendremos que pasar el identificador del recurso al método **activity.getResources().getDrawable**. Una vez finalizado con la imagen, el texto del nombre y del tipo no tiene ningún misterio, obtenemos los controles adecuados y les asignamos el texto con el método **setText**. Finalmente devolvemos la vista terminada de configurar.

Una vez terminado esto, el trabajo más difícil ha sido completado, nos queda configurar la pantalla principal de la aplicación para indicar que muestre un ListView. Para ello vamos al layout *main.xaml* y lo dejamos de la siguiente forma:

{% highlight xml linenos %}
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    android:orientation="vertical" >

    <ListView
        android:layout_width="fill_parent"
        android:layout_height="wrap_content"
        android:id="@+id/listView" />
</LinearLayout>
{% endhighlight %}

Para acabar con el ejemplo vamos al fichero de inicio de la aplicación *ListViewSampleActivity.java* y escribimos lo siguiente:

{% highlight java linenos %}
class ListViewSampleActivity extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        ListView lv = (ListView)findViewById(R.id.listView);
        
        ArrayList<ItemCompra> itemsCompra = obtenerItems();
        
        ItemCompraAdapter adapter = new ItemCompraAdapter(this, itemsCompra);
        
        lv.setAdapter(adapter);    
    }
    
    private ArrayList<ItemCompra> obtenerItems() {
        ArrayList<ItemCompra> items = new ArrayList<ItemCompra>();

        items.add(new ItemCompra(1, "Patatas", "Tuberculo", 
            "drawable/patatas"));
        items.add(new ItemCompra(2, "Naranja", "Fruta", 
            "drawable/naranjas"));
        items.add(new ItemCompra(3, "Lechuga", "Verdura", 
            "drawable/lechuga"));

        return items;
    }
}
{% endhighlight %}

La funcionalidad principal aquí es recuperar el ListView y obtener un ArrayList con los elementos, en este ejemplo se ha optado por crear los elementos de uno en uno, pero se pueden obtener desde una base de datos, desde un fichero o como queramos. A  continuación se crea el adapter y finalmente se le asigna el adapter al ListView. Con esto el resultado que obtenemos es el siguiente:

![Android ListView](/uploads/posts/images/android-listview.png)

Como se ha podido ver, personalizar los items no es una tarea tan complicada como podría parecer, lleva un poco de trabajo pero es bastante sencillo hacerlo. Para descargar el ejemplo completo, podéis hacerlo desde [aquí](/uploads/posts/samples/AndroidListViewSample.zip).