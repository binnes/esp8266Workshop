*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
***
**Part 2** - [Device Registration](DEVICE.md) - [**Application**](APP.md) - [MQTT](MQTT.md) - [Server Certificate](CERT1.md) - [Client Certificate](CERT2.md)
***

# Creating the sensing application for the ESP8266

## Lab Objectives

In this lab you will pull together all the information from part 1 into a single app.  You will learn:

- How to create a new sketch and some recommendations for app structure
- How to combine the WiFi, neopixel and DHT libraries into a single application
- How to work with JSON data on the ESP8266

## Introduction

In part 1 you looked at a number of example sketches to see how the WiFi, NeoPixel LED and DHT sensors work with Arduino.  Now you will create an application combining all the features then as we work through the remainder of this part you will connect the device to the IoT platform and add code to send data to the platform and receive commands from the platform.  Initially you will use unsecured MQTT connections, then at the end of this section you will add SSL/TLS and certificate verification to secure the communication.

### Step 1 - Create a new sketch

Create a new sketch in the Arduino IDE using *File* -> *New* or the icon in the tool bar.  The save the sketch *File* -> *Save* and name the sketch, suggested name **esp8266Workshop**.

You need to add 1 more library to the Arduino IDE to provide functions to handle the JSON data format.  When we start sending and receiving data from the IoT Platform the JSON data format will be used, so we can start using JSON now.  In the Library Manager (*Sketch* -> *Include Library* -> *Manage Libraries...*) search for **ArduinoJson** and install the latest v5.x version of the library.

**Note, do not use beta versions of the ArduinoJson library, stick to the latest released v5.x versions.  You can use the drop down in the library manager to select which version of the library to install.  If you have installed v6 beta, then use the library manager to replace the version with the latest 5.x.x release of the library.  You will get a compile error if you use v6 with the bootcamp code.**

### Step 2 - Input the application code

I've provided the code for the application below.  As you enter it (or cut and paste it) please take time to ensure you understand the application and what each of the library function calls do.

Add the code below to the sketch above the **setup()** function:

```C++
#include <ESP8266WiFi.h>
#include <Adafruit_NeoPixel.h>
#include <DHT.h>
#include <ArduinoJson.h>

// --------------------------------------------------------------------------------------------
//        UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT
// --------------------------------------------------------------------------------------------

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
char ssid[] = "XXXX";  // your network SSID (name)
char pass[] = "YYYY";  // your network password


// --------------------------------------------------------------------------------------------
//        SHOULD NOT NEED TO CHANGE ANYTHING BELOW THIS LINE
// --------------------------------------------------------------------------------------------
Adafruit_NeoPixel pixel = Adafruit_NeoPixel(1, RGB_PIN, NEOPIXEL_TYPE);
DHT dht(DHT_PIN, DHTTYPE);

// variables to hold data
StaticJsonBuffer<100> jsonBuffer;
JsonObject& payload = jsonBuffer.createObject();
JsonObject& status = payload.createNestedObject("d");
static char msg[50];
float h = 0.0; // humidity
float t = 0.0; // temperature
unsigned char r = 0; // LED RED value
unsigned char g = 0; // LED Green value
unsigned char b = 0; // LED Blue value

```

The above code isolates all the configuration that may need to change.  I prefer to put all the config up front in an app, so it is easy to update as needed.  You will need to update the WiFI SSID and password to the WiFi network you want to connect to.  This should be available in the venue you are working in.

Add the following code to the **setup()** function:

```C++
void setup()
{
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
}
```

This function initialises the Serial port, the WiFi connection, the LED and the DHT sensor.

The loop function should contain:

```C++
void loop()
{
  h = dht.readHumidity();
  t = dht.readTemperature(); // uncomment this line for Celsius
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

    // Print Message to console in JSON format
    status["temp"] = t;
    status["humidity"] = h;
    payload.printTo(msg, 50);
    Serial.println(msg);
  }
  delay(10000);
}
```

This code is called repeatedly after the **setup()** function returns.  It reads the humidity and temperature for the DHT sensor, validates it received the readings then sets the LED colour to the correct colour based on the temperature and the alert and warning temperatures defined in the constants at the top of the application.  Finally the temperature and humidity values are added to the JSON object, which is then converted to a string buffer and printed to the console.

### Step 3 - Run the code and view output using the Serial Monitor

Save, compile and upload the sketch.  Once uploaded open up the Serial Monitor and set the baud rate to 115200, to match the rate set in the Serial.begin(115200) message.  You should see the confirmation that the WiFi connection has been made and then you should see the sensor data formatted as a JSON string, repeating every 10 seconds (10000 milliseconds).

The LED should also be set to a colour based on the temperature and the WARN and ALARM constants defined at the top of the sketch :

- BLUE (below ALARM_COLD)
- TURQUOISE (between ALARM_COLD and WARM_COLD)
- GREEN (between WARN_COLD and WARN_HOT)
- YELLOW (between WARN_HOT and ALARM_HOT)
- RED (above ALARM_HOT)

### Step 4 - Understanding how to work with JSON data

JSON format is widely used for APIs and data exchange between systems.  The above sketch uses one of the optimised JSON libraries for small memory devices.  To use the library you need to:

1. Initialise the library and allocate some memory for the library to work with : `StaticJsonBuffer<100> jsonBuffer;`
2. Create a new, empty JSON object : `JsonObject& payload = jsonBuffer.createObject();`
3. Add required properties using one of the available functions:

    ```C++
    JsonObject& status = payload.createNestedObject("d");
    status["temp"] = t;
    status["humidity"] = h;
    ```

The **printTo()** function converts the JSON object to a string and writes it into the provided buffer, so it can be used as a c-string.

See the library [documentation](https://arduinojson.org/?utm_source=meta&utm_medium=library.properties) for additional functionality.

***
**Part 2** - [Device Registration](DEVICE.md) - [**Application**](APP.md) - [MQTT](MQTT.md) - [Server Certificate](CERT1.md) - [Client Certificate](CERT2.md)
***
*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
