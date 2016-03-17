---
layout: post
comments: false
title: Obtener imagen almacenada en MySQL desde Android
---

Un usuario de la web me preguntó como podría hacer que una aplicación Android obtenga y muestre una imagen que está alojada en una base de datos MySQL que se encuentra en un servidor remoto. Con la finalidad de aclararle esta duda he decidido redactar esta entrada.

Android no tiene ninguna función en su SDK para poder atacar a una base de datos MySQL, así que para poder obtener datos de este tipo de base de datos utilizaremos un servicio web. La aplicación Android se encargará de realizar peticiones al servicio y este le devolverá la información solicitada. Si tienes más curiosidad por los servicios web, puedes darle un vistazo a la entrada [servicio web en php](/2011/01/18/servicio-web-php.html). En este ejemplo vamos a usar un servicio muy sencillo de tipo [REST](http://es.wikipedia.org/wiki/REST).

La aplicación que vamos a crear como ejemplo mostrará nombres de ciudades y una imagen de ellas. Para comenzar crearemos una base de datos MySQL a la que llamaremos *cities* y que contendrá una única tabla que también llamaremos *cities*. Esta tabla contendrá un identificador que llamaremos *id*, el cual será de tipo entero y autoincrementable, el nombre de la ciudad *name* un varchar de 150 caracteres y la imagen *photo* un mediumblob. [Aquí](/uploads/posts/samples/cities.sql) dejo el script para poder descargar, crear y tener algunos datos de la base de datos.

El servicio web que crearemos para recuperar la información de esta base de datos contendrá un fichero al que llamaremos *cities.php* y su contenido será el siguiente:

<!--more-->

{% highlight php linenos %}
<?php  

$con = mysql_connect('localhost', 'root', '');  
mysql_query("SET CHARACTER SET utf8");  
mysql_query("SET NAMES utf8");  

$cities['cities'] = array();

if( $con )  
{  
    mysql_select_db('cities');  

    $res = mysql_query('select id, name, photo from cities');
  
    while( $row = mysql_fetch_array($res) ) {
        array_push($cities['cities'], array(
            'id'    => $row['id'], 
            'name'  => $row['name'], 
            'photo' => base64_encode($row['photo'])
        ));
    }
    mysql_free_result($res);
    mysql_close($con);
}

header('Content-type: application/json');
echo json_encode($cities);
{% endhighlight %}

El servicio nos devolverá en formato json el identificador, el nombre y la imagen codificada en base64 de todas las ciudades de nuestra base de datos. Con el servicio web finalizado a continuación pasamos a la aplicación Android. Lo primero que vamos a crear es el layout para el ListView el cual tendrá un ImageView donde se alojará la imagen de la ciudad y un TextView donde se mostrará su nombre. Para el layout crearemos un fichero en la carpeta *layout* al que llamaremos **list_item_layout.xml** y su contenido será el siguiente:

{% highlight xml linenos %}
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="wrap_content" >
 
    <ImageView
        android:id="@+id/cityImage"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_alignParentLeft="true"
        android:layout_centerInParent="true"/>
     
    <TextView
        android:id="@+id/cityName"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerVertical="true"
        android:layout_centerHorizontal="true"
        android:text="Large Text"
        android:textAppearance="?android:attr/textAppearanceLarge" />
    
</RelativeLayout>
{% endhighlight %}

Con este layout definido, vamos ahora con el layout principal de la aplicación. Este otro layout únicamente contendrá un ListView donde se mostrarán los datos, también lo situaremos en la carpeta *layout*, su nombre será **main.xml** y su contenido será el siguiente:

{% highlight xml linenos %}
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="fill_parent"
    android:layout_height="fill_parent"
    android:orientation="vertical" >

    <ListView 
        android:layout_width="fill_parent"
        android:layout_height="fill_parent"
        android:id="@+id/lv_cities">
    </ListView>
    
</LinearLayout>
{% endhighlight %}

Una vez finalizados los layouts de nuestra aplicación, vamos a pasar ahora a implementar el modelo. En este caso el modelo solo tendrá una clase a la que llamaremos **City** y su contenido será el siguiente:

{% highlight java linenos %}
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;

public class City {
    protected int id;
    protected String name;
    protected String data;
    protected Bitmap photo;

    public City(int id, String name) {
        this.id = id;
        this.name = name;
    }
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
        try {
            byte[] byteData = Base64.decode(data, Base64.DEFAULT);
            this.photo = BitmapFactory.decodeByteArray( byteData, 0, 
                byteData.length);
        }
        catch(Exception e) {
            e.printStackTrace();
        }
    }

    public Bitmap getPhoto() {
        return photo;
    }
}
{% endhighlight %}

Como vemos, nuestra clase City contiene atributos para almacenar su id, nombre y su imagen. Para almacenar la imagen se utiliza el atributo *data* que recuperará la imagen en base64 del webservice, posteriormente se decodificaran esos datos y se convertirán en un Bitmap que se almacenará en el atributo *photo*. Ese atributo *photo* será el usado para aplicarlo al ImageView. Además de los atributos, hemos incluido los métodos geters y setter, el único que tiene algo especial es el método **setData** que además de asignar el valor a su variable, la decodificará, creará el Bitmap y lo asignará al atributo *photo*.

El siguiente paso es crear la clase que usaremos como adapter para nuestro ListView, a esta clase la llamaremos **CityAdapter** y su contenido será el siguiente:


{% highlight java linenos %}
public class CityAdapter extends BaseAdapter {
    protected Activity activity;
    protected ArrayList<City> items;

    public CityAdapter(Activity activity, ArrayList<City> items) {
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
    public View getView(int position, View convertView, ViewGroup parent) {
        View vi=convertView;
         
        if(convertView == null) {
            LayoutInflater inflater = (LayoutInflater) activity
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            vi = inflater.inflate(R.layout.list_item_layout, null);
        }
         
        City city = items.get(position);
         
        ImageView image = (ImageView) vi.findViewById(R.id.cityImage);
        image.setImageBitmap(city.getPhoto());
             
        TextView name = (TextView) vi.findViewById(R.id.cityName);
        name.setText(city.getName());
        
        return vi;
    }
}
{% endhighlight %}

Ahora completaremos el código del método *onCreate* del Activity para que todo se ejecute correctamente:

{% highlight java linenos %}
public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.main);
        
    ListView lvCities = (ListView) findViewById(R.id.lv_cities);
    ArrayList<City> citiesAvaiable = new ArrayList<City>();
        
    try {
        // Llamamos al servicio web para recuperar los datos
        HttpGet httpGet = new HttpGet(
            "http://192.168.1.134/CitiesService/cities.php");
        HttpClient httpClient = new DefaultHttpClient();
        HttpResponse response = (HttpResponse)httpClient.execute(httpGet);
        HttpEntity entity = response.getEntity();
        BufferedHttpEntity buffer = new BufferedHttpEntity(entity);
        InputStream iStream = buffer.getContent();
                        
        String aux = "";
                
        BufferedReader r = new BufferedReader(new InputStreamReader(iStream));
        StringBuilder total = new StringBuilder();
        String line;
        while ((line = r.readLine()) != null) {
            aux += line;
        }
        
        // Parseamos la respuesta obtenida del servidor a un objeto JSON
        JSONObject jsonObject = new JSONObject(aux);
        JSONArray cities = jsonObject.getJSONArray("cities");
    
        // Recorremos el array con los elementos cities
        for(int i = 0; i < cities.length(); i++) {
            JSONObject city = cities.getJSONObject(i);
    
            // Creamos el objeto City
            City c = new City(city.getInt("id"), city.getString("name"));
            c.setData(city.getString("photo"));
    
            // Almacenamos el objeto en el array que hemos creado anteriormente
            citiesAvaiable.add(c);
        }
    }
    catch(Exception e) {
        Log.e("WebService", e.getMessage());
    }
             
    // Creamos el objeto CityAdapter y lo asignamos al ListView 
    CityAdapter cityAdapter = new CityAdapter(this, citiesAvaiable);
    lvCities.setAdapter(cityAdapter);
}
{% endhighlight %}

Una cosa que hay que tener en cuenta cuando estamos desarrollando y tenemos en la misma máquina el servidor web y el emulador de Android, es que para  llamar al servicio web tenemos que usar la IP de la maquina en la que estamos trabajando. En el ejemplo yo he usado la IP 192.168.1.134 que es la que tenía asignada. Si dentro del código de Android usamos localhost no obtendríamos respuesta del servicio web ya que nos estaríamos refiriendo al propio emulador de Android.

Para terminar, tenemos que darle permiso a la aplicación para el acceso a internet. Esto lo hacemos en el fichero **AndroidManifest.xml** que nos quedará de la siguiente manera:

{% highlight xml linenos %}
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="es.jhernandz"
    android:versionCode="1"
    android:versionName="1.0" >

    <uses-sdk android:minSdkVersion="8" />
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:icon="@drawable/ic_launcher"
        android:label="@string/app_name" >
        <activity
            android:label="@string/app_name"
            android:name=".WebServiceSampleActivity" >
            <intent-filter >
                <action android:name="android.intent.action.MAIN" />

                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
{% endhighlight %}

Con todos los pasos finalizados es hora de ejecutar tanto el servidor web donde esta alojado el servicio como la aplicación Android para comprobar que todo funciona correctamente.

Aquí dejo un [enlace](/uploads/posts/samples/GetImageFromMySqlProject.zip) para poder descargar el proyecto.