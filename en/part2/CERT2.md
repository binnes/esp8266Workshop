*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
***
**Part 2** - [Device Registration](DEVICE.md) - [Application](APP.md) - [MQTT](/MQTT.md) - [Server Certificate](CERT1.md) - [**Client Certificate**](CERT2.md)
***

# Using a Device Certificate to authenticate to the Watson IoT platform

## Lab Objectives

In this lab you will extend the application by enabling client side certificates.  You will learn how to:

- Generate client keys and certificates
- Modify the application to use the client certificates
- Configure the IoT platform connection policy to require tokens and/or certificates

### Step 1 - Generating the key and certificate for a device

The openssl tool must be used to generate the key and certificate, as in the previous lab.  You need to work in the same directory as you did in the previous lab, as the commands below need access to the rootCA_certificate.pem file.  If you altered the root CA key password, then remember to change the value in the commands shown below:

```Shell
COUNTRY="GB"
STATE="DOR"
LOCATION="Bournemouth"
ORG_ID="z53u40"
PASSWORD="password123"
DEV_TYPE="ESP8266"
DEV_ID="dev01"

openssl genrsa -aes256 -passout pass:${PASSWORD} -out SecuredDev01_key.pem 2048
openssl req -new -sha256 -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORG_ID}/OU=${ORG_ID} Corporate/CN=d:${DEV_TYPE}:${DEV_ID}" -passin pass:${PASSWORD} -key SecuredDev01_key.pem -out SecuredDev01_crt.csr
openssl x509 -days 3650 -in SecuredDev01_crt.csr -out SecuredDev01_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:${PASSWORD} -CAkey rootCA_key.pem -set_serial 131
openssl rsa -outform der -in SecuredDev01_key.pem -passin pass:${PASSWORD} -out SecuredDev01_key.key
openssl x509 -outform der -in SecuredDev01_crt.pem -out SecuredDev01_crt.der
```

where `DEV_TYPE` and `DEV_ID` are, respectively, the device type and device ID you used when the device was registered.

### Step 2 - Upload the certificate and key to the ESP8266 device

You need to add the private key (SecuredDev01_key.key) and the certificate (SecuredDev01_crt.der) to the data folder inside the sketch folder then run the data uploader tool (*Tools* -> *ESP8266 Sketch Data Upload*) to install the certificates on the device filesystem.

### Step 3 - Modify the application to use the client certificate and key

Now you can modify the code to load the certificates and add them to the connection:

Add two mode #define statements containing the names of the key and certificate:

```C++
#define KEY_FILE "/SecuredDev01_key.key"
#define CERT_FILE "/SecuredDev01_crt.der"
```

then update the code within the setup() function to load the additional key and certificate:

```C++
// Get certs from file system and load into WiFiSecure client
  SPIFFS.begin();
  File ca = SPIFFS.open(CA_CERT_FILE, "r");
  if(!ca) {
    Serial.println("Couldn't load CA cert");
  } else {
    bool ret = wifiClient.loadCACert(ca);
    Serial.print("Loading CA cert returned ");
    Serial.println((ret)? "true" : "false");
    ca.close();
  }
  File key = SPIFFS.open(KEY_FILE, "r");
  if(!key) {
    Serial.println("Couldn't load key");
  } else {
    bool ret = wifiClient.loadPrivateKey(key);
    Serial.print("Loading key returned ");
    Serial.println((ret)? "true" : "false");
    key.close();
  }
  File cert = SPIFFS.open(CERT_FILE, "r");
  if(!cert) {
    Serial.println("Couldn't load cert");
  } else {
    bool ret = wifiClient.loadCertificate(cert);
    Serial.print("Loading cert returned ");
    Serial.println((ret)? "true" : "false");
    cert.close();
  }
```

### Step 4 - Run the application

Save, compile and upload the sketch to the device and verify the device connects.

### Step 5 - Configure the security policy on the IoT platform

You now have client certificates working with the device, so can now choose how you want devices to be verified.  If you open the IoT Platform console and got to the settings section then the Connection Security section and Open Connection Security Policy you see you have a number of options:

- TLS Optional
- TLS with Token Authentication
- TLS with Client Certificate Authentication
- TLS with Client Certificate AND Token Authentication
- TLS with Client Certificate OR Token Authentication

You can now decide what policy you want.  If you don't want to use Token Authentication then change the **connect()** function call and omit the user and token information:

- with token authentication : `if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {`
- without token authentication : `if (mqtt.connect(MQTT_DEVICEID)) {`

You will also see that you can create Custom Rules in addition to the Default Rule.  This allows different device types to have a different policy . If a device type doesn't match a custom rule then the default rule is used.

### Solution Code

The finished application should look like this:

```C++
#include <FS.h>
#include <ESP8266WiFi.h>
#include <time.h>
#include <Adafruit_NeoPixel.h>
#include <DHT.h>
#include <ArduinoJson.h>
#include <PubSubClient.h>

// --------------------------------------------------------------------------------------------
//        UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT
// --------------------------------------------------------------------------------------------

// Watson IoT connection details
#define MQTT_HOST "z53u40.messaging.internetofthings.ibmcloud.com"
#define MQTT_PORT 8883
#define MQTT_DEVICEID "d:z53u40:ESP8266:dev01"
#define MQTT_USER "use-token-auth"
#define MQTT_TOKEN "password"
#define MQTT_TOPIC "iot-2/evt/status/fmt/json"
#define MQTT_TOPIC_DISPLAY "iot-2/cmd/display/fmt/json"
#define CA_CERT_FILE "/rootCA_certificate.der"
#define KEY_FILE "/SecuredDev01_key.key"
#define CERT_FILE "/SecuredDev01_crt.der"

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

//Timezone info
#define TZ_OFFSET -5  //Hours timezone offset to GMT (without daylight saving time)
#define TZ_DST    60  //Minutes timezone offset for Daylight saving

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
WiFiClientSecure wifiClient;
PubSubClient mqtt(MQTT_HOST, MQTT_PORT, callback, wifiClient);

// variables to hold data
StaticJsonDocument<100> jsonDoc;
JsonObject payload = jsonDoc.to<JsonObject>();
JsonObject status = payload.createNestedObject("d");
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
  Serial.print("] : ");

  payload[length] = 0; // ensure valid content is zero terminated so can treat as c-string
  Serial.println((char *)payload);
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

  // Get certs from file system and load into WiFiSecure client
  SPIFFS.begin();
  File ca = SPIFFS.open(CA_CERT_FILE, "r");
  if(!ca) {
    Serial.println("Couldn't load CA cert");
  } else {
    bool ret = wifiClient.loadCACert(ca);
    Serial.print("Loading CA cert returned ");
    Serial.println((ret)? "true" : "false");
    ca.close();
  }
  File key = SPIFFS.open(KEY_FILE, "r");
  if(!key) {
    Serial.println("Couldn't load key");
  } else {
    bool ret = wifiClient.loadPrivateKey(key);
    Serial.print("Loading key returned ");
    Serial.println((ret)? "true" : "false");
    key.close();
  }
  File cert = SPIFFS.open(CERT_FILE, "r");
  if(!cert) {
    Serial.println("Couldn't load cert");
  } else {
    bool ret = wifiClient.loadCertificate(cert);
    Serial.print("Loading cert returned ");
    Serial.println((ret)? "true" : "false");
    cert.close();
  }

  // Set time from NTP servers
  configTime(TZ_OFFSET * 3600, TZ_DST * 60, "pool.ntp.org", "0.pool.ntp.org");
  Serial.println("\nWaiting for time");
  unsigned timeout = 5000;
  unsigned start = millis();
  while (millis() - start < timeout) {
      time_t now = time(nullptr);
      if (now > (2018 - 1970) * 365 * 24 * 3600) {
          break;
      }
      delay(100);
  }
  delay(1000); // Wait for time to fully sync
  Serial.println("Time sync'd");
  time_t now = time(nullptr);
  Serial.println(ctime(&now));

  // Connect to MQTT - IBM Watson IoT Platform
   while(! mqtt.connected()){
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) { // Token Authentication
//    if (mqtt.connect(MQTT_DEVICEID)) { // No Token Authentication
      if (wifiClient.verifyCertChain(MQTT_HOST)) {
        Serial.println("certificate matches");
      } else {
        // ignore for now - but usually don't want to proceed if a valid cert not presented!
        Serial.println("certificate doesn't match");
      }
      Serial.println("MQTT Connected");
      mqtt.subscribe(MQTT_TOPIC_DISPLAY);
    } else {
      Serial.println("MQTT Failed to connect! ... retrying");
      delay(500);
    }
  }
}

void loop() {
  mqtt.loop();
  while (!mqtt.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) { // Token Authentication
//    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) { // No Token Authentication
      Serial.println("MQTT Connected");
// Should verify the certificates here - like in the startup function
      mqtt.subscribe(MQTT_TOPIC_DISPLAY);
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
    serializeJson(jsonDoc, msg, 50);
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
**Part 2** - [Device Registration](DEVICE.md) - [Application](APP.md) - [MQTT](MQTT.md) - [Server Certificate](CERT1.md) - [**Client Certificate**](CERT2.md)
***
*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)