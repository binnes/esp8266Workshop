*Quick links :*
[Home](/README.md) - [Part 1](/part1/README.md) - [**Part 2**](/part2/README.md) - [Part 3](/part3/README.md) - [Part 4](/part4/README.md)
***
**Part 2** - [Device Registration](/part2/DEVICE.md) - [Application](/part2/APP.md) - [**MQTT**](/part2/MQTT.md) - [Server Certificate](/part2/CERT1.md) - [Client Certificate](/part2/CERT2.md)
***

# Connecting Device to the Watson IoT Platform using MQTT

## Lab Objectives

In this lab you will learn how to add MQTT messaging to an application.  You will learn:

- How to connect to a MQTT broker using unsecured connection
- How to use MQTT to connect to the Watson IoT platform

### Introduction

In the previous lab you built the stand alone sensor application.  Now we want to make it an Internet of Things application by adding in MQTT to send the data to the IoT Platform.

We will start by using an unsecured MQTT connection, then in the next section we will secure the connection.  However, the Watson IoT platform is configured to block all unsecured connections by default, so you need to configure your Watson IoT instance to allow unsecured connection.

### Step 1 - Configure the Watson IoT platform to allow unsecured connections

Open up the IoT platform console for the instance connected to your Boilerplate application.  From the dashboard (*≡* -> *Dashboard*) select the application then in the overview section select the IoT platform in the connections panel).

Launch the IoT platform console, then switch to the Settings section.  Under Security select Connection Security then press the button **Open Connection Security Policy**.  Change the Default Security Level to **TLS Optional**, accept the Warning message by pressing the Ok button, then **Save** the change.  Your IoT platform instance will now accept unsecured MQTT connections.  Leave the browser window showing the IoT Platform console open, as you'll need to get some information when adding the MQTT code to the ESP8266 application.

### Step 2 - Enhancing the application to send data to the IoT platform

In the Arduino IDE you need to add the MQTT code, but before adding the MQTT code you need to install the library.  In the library manager (*Sketch* -> *Include Library* -> *Manage Libraries...*) search for and install the PubSubClient.  Then add the include to the top of the application, below the existing include files

`#include <PubSubClient.h>`

Now add some #define statements to contain that the MQTT code will use.  Add these under the comment **UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT**:

```C++
// --------------------------------------------------------------------------------------------
//        UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT
// --------------------------------------------------------------------------------------------

// Watson IoT connection details
#define MQTT_HOST "XXXXXX.messaging.internetofthings.ibmcloud.com"
#define MQTT_PORT 1883
#define MQTT_DEVICEID "d:XXXXXX:YYYY:ZZZZ"
#define MQTT_USER "use-token-auth"
#define MQTT_TOKEN "PPPPP"
#define MQTT_TOPIC "iot-2/evt/status/fmt/json"
#define MQTT_TOPIC_CMD "iot-2/cmd/display/fmt/json"
```

You need to change the values to match your configuration:

- XXXXXX should be the 6 character Organisation ID for your platform.  If you look in the settings section of the IoT Platform console, under identity you will see the value you need to use.
- YYYY is the device type you used to for the ESP8266 device.  This should be ESP8266, but you can verify by looking in the devices section.  All registered devices are listed here, and you can see the Device Type and Device ID.
- ZZZZ is the device ID for your ESP8266, in the lab it was suggested to use dev01
- PPPPP is the token you used when registering the device (hopefully you haven't forgot what you used, if so you need to delete the device and reregister it)

After the configuration block and under the pixel and dht variable declarations you need to add the the following:

```C++
// MQTT objects
void callback(char* topic, byte* payload, unsigned int length);
WiFiClient wifiClient;
PubSubClient mqtt(MQTT_HOST, MQTT_PORT, callback, wifiClient);
```

Above the setup() function add the implementation of the callback function.  This is called whenever a MQTT message is sent to the device.  For now it just prints a message to the serial console:

```C++
void callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.println("] ");
}
```

at the end of the setup() function add the following code to connect the MQTT client to the IoT Platform:

```C++
  // Connect to MQTT - IBM Watson IoT Platform
  if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
    Serial.println("MQTT Connected");
    mqtt.subscribe(MQTT_TOPIC_CMD);

  } else {
    Serial.println("MQTT Failed to connect!");
    ESP.reset();
  }
```

at the top of the loop() function add the following code to verify the mqtt connection is still valid and call the mqtt.loop() function to process any outstanding messages:

```C++
  mqtt.loop();
  while (!mqtt.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
      Serial.println("MQTT Connected");
      mqtt.subscribe(MQTT_TOPIC_CMD);
      mqtt.loop();
    } else {
      Serial.println("MQTT Failed to connect!");
      delay(5000);
    }
  }
```

Lastly add the code to send the data to the IoT Platform.  We already have the data formatted as a JSON string, so we can now add the following code after it is printed to the console in the **loop()** function:

```C++
    Serial.println(msg);
    if (!mqtt.publish(MQTT_TOPIC, msg)) {
      Serial.println("MQTT Publish failed");
    }
```

Finally, replace the 10 second ```delay(10000)``` to call the mqtt **loop()** function, so the program processes incoming messages:

```C++
  // Pause - but keep polling MQTT for incoming messages
  for (int i = 0; i < 10; i++) {
    mqtt.loop();
    delay(1000);
  }
```

### Step 3 - Run the application

Compile and upload the code to your ESP8266 and you should see the ```WiFi Connected```, followed by ```Attempting MQTT connection...MQTT Connected```. Every 10 second interval you see the DHT sensor data printed on the console.  The ESP8266 should also be publishing MQTT messages to the Watson IoT Platform.  To verify this, switch to your browser window showing the IoT Platform console, switch to the Devices section.  Click on the esp8266 device to expand it then click **Recent Events**.  You should see the status event messages with the live data appearing every 10 seconds.

### Step 4 - How it works

When connecting to the Watson IoT platform there are some requirements on some parameters used when connecting.  The [platform documentation](https://console.bluemix.net/docs/services/IoT/reference/security/connect_devices_apps_gw.html#connect_devices_apps_gw) provides full details:

1. The #define statements construct the required parameters:
   - host : < **org id** >.messaging.internetofthings.ibmcloud.com
   - device ID : d:< **org id** >:< **device type** >:< **device id** >
   - topic to publish data : iot-2/evt/< **event id** >/fmt/<  **format string** >
   - topic to receive commands : iot-2/cmd/< **command id** >/fmt/< **format string** >
2. When you initialise the PubSubClient you need to pass in the hostname, the port (1883 for unsecured connections), a callback function and a network connection.  The callback function is called whenever incoming messages are received.
3. Call **connect()** to connect with the platform, passing in the device ID, a user, which is always the value *use-token-auth* and the token you chose when registering the device.
4. The **subscribe()** function registers the connection to receive messages published on the given topic.
5. The **loop()** method must be regularly called to keep the connection alive and get incoming messages.
6. The **publish()** function sends data on the provided topic - *Note*: On some MQTT Clients this function only queues the message for sending, it is actually sent in the **loop()** function.
7. You can verify the connection status with the **connected()** function.

### Solution code

The complete ESP8266 application is shown below (you will need to change the configuration section to match your environment):

```C++
#include <ESP8266WiFi.h>
#include <Adafruit_NeoPixel.h>
#include <DHT.h>
#include <ArduinoJson.h>
#include <PubSubClient.h>

// --------------------------------------------------------------------------------------------
//        UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT
// --------------------------------------------------------------------------------------------

// Watson IoT connection details
#define MQTT_HOST "z53u40.messaging.internetofthings.ibmcloud.com"
#define MQTT_PORT 1883
#define MQTT_DEVICEID "d:z53u40:ESP8266:dev01"
#define MQTT_USER "use-token-auth"
#define MQTT_TOKEN "password"
#define MQTT_TOPIC "iot-2/evt/status/fmt/json"
#define MQTT_TOPIC_CMD "iot-2/cmd/display/fmt/json"

// Add GPIO pins used to connect devices
#define RGB_PIN 5 // GPIO pin the data line of RGB LED is connected to
#define DHT_PIN 4 // GPIO pin the data line of the DHT sensor is connected to

// Specify DHT11 (Blue) or DHT22 (White) sensor
#define DHTTYPE DHT11
#define NEOPIXEL_TYPE NEO_RGB + NEO_KHZ800

// Temperatures to set LED by (assume temp in C)
#define ALARM_COLD 0.0
#define ALARM_HOT 30.0
#define WARN_COLD 10.0
#define WARN_HOT 25.0


// Add WiFi connection information
char ssid[] = "SSID";     //  your network SSID (name)
char pass[] = "WiFi_password";  // your network password


// --------------------------------------------------------------------------------------------
//        SHOULD NOT NEED TO CHANGE ANYTHING BELOW THIS LINE
// --------------------------------------------------------------------------------------------
Adafruit_NeoPixel pixel = Adafruit_NeoPixel(1, RGB_PIN, NEOPIXEL_TYPE);
DHT dht(DHT_PIN, DHTTYPE);


// MQTT objects
void callback(char* topic, byte* payload, unsigned int length);
WiFiClient wifiClient;
PubSubClient mqtt(MQTT_HOST, MQTT_PORT, callback, wifiClient);

// variables to hold data
StaticJsonBuffer<100> jsonBuffer;
JsonObject& payload = jsonBuffer.createObject();
JsonObject& status = payload.createNestedObject("d");
static char msg[50];

float h = 0.0;
float t = 0.0;

unsigned char r = 0;
unsigned char g = 0;
unsigned char b = 0;

void callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.println("] ");
}

void setup() {
 // Start serial console
  Serial.begin(115200);
  Serial.setTimeout(2000);
  while (!Serial) { }
  Serial.println();
  Serial.println("ESP8266 Sensor Application");

  // Start WiFi connection
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, pass);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi Connected");

  // Start connected devices
  dht.begin();
  pixel.begin();

  // Connect to MQTT - IBM Watson IoT Platform
  if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
    Serial.println("MQTT Connected");
    mqtt.subscribe(MQTT_TOPIC_CMD);

  } else {
    Serial.println("MQTT Failed to connect!");
    ESP.reset();
  }
}

void loop() {
  mqtt.loop();
  while (!mqtt.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
      Serial.println("MQTT Connected");
      mqtt.subscribe(MQTT_TOPIC_CMD);
      mqtt.loop();
    } else {
      Serial.println("MQTT Failed to connect!");
      delay(5000);
    }
  }
  h = dht.readHumidity();
  t = dht.readTemperature(); // uncomment this line for centigrade
  // t = dht.readTemperature(true); // uncomment this line for Fahrenheit

  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
  } else {
    // Set RGB LED Colour based on temp
    b = (t < ALARM_COLD) ? 255 : ((t < WARN_COLD) ? 150 : 0);
    r = (t >= ALARM_HOT) ? 255 : ((t > WARN_HOT) ? 150 : 0);
    g = (t > ALARM_COLD) ? ((t <= WARN_HOT) ? 255 : ((t < ALARM_HOT) ? 150 : 0)) : 0;
    pixel.setPixelColor(0, r, g, b);
    pixel.show();

    // Send data to Watson IoT Platform
    status["temp"] = t;
    status["humidity"] = h;
    payload.printTo(msg, 50);
    Serial.println(msg);
    if (!mqtt.publish(MQTT_TOPIC, msg)) {
      Serial.println("MQTT Publish failed");
    }
  }

  // Pause - but keep polling MQTT for incoming messages
  for (int i = 0; i < 10; i++) {
    mqtt.loop();
    delay(1000);
  }
}
```

***
**Part 2** - [Device Registration](/part2/DEVICE.md) - [Application](/part2/APP.md) - [**MQTT**](/part2/MQTT.md) - [Server Certificate](/part2/CERT1.md) - [Client Certificate](/part2/CERT2.md)
***
*Quick links :*
[Home](/README.md) - [Part 1](/part1/README.md) - [**Part 2**](/part2/README.md) - [Part 3](/part3/README.md) - [Part 4](/part4/README.md)
