# Adding secure communication between the device and MQTT broker using SSL/TLS

## Lab Objectives

In this Lab you will modify MQTT to use a secure connection.  You will learn:

- How to add SSL/TLS capability to the network connection that MQTT uses
- How to add the certificate to the ESP8266 using part of the flash memory as a file system
- Basic operations of the ESP8266 file system

## Introduction

Having unsecured traffic for an IoT solution is not a good idea, so in this lab you will use the Internet security standards and protocols covered in the previous section to convert the unsecured MQTT connection into an SSL/TLS connection.

When using SSL/TLS you can verify the certificate(s) presented by the server if you have the certificate of the Root Certificate Authority used to sign the server certificate.  Your Laptop will have root certificate authority (CA) certificates installed as part of the operating system or browser so web traffic can be secured and the padlock on your browser can be shown.  However, you need to add any root CA certificate to IoT devices if you want to verify server certificates.

### Step 1 - Download the Root CA Certificate

The CloudAMQP [FAQ](https://www.cloudamqp.com/docs/faq.html#does-cloudamqp-support-tlsssl-+-certificate){target=_blank} provides details about the root CA used to secure SSL connection  Download the root CA certificate from [link](http://crt.usertrust.com/USERTrustRSAAddTrustCA.crt){target=_blank} on that site.

### Step 2 - Convert the certificate to PEM format

X.509 certificates are usually present in 1 of 2 formats:

- PEM : A text based format using ASCII Base64 encoding
- DER : A binary encoding

You can also come across different file extensions .crt and .cer, which can be either PEM or DER encodings.  You can recognise PEM encoded files as the Base64 data is between lines **-----BEGIN CERTIFICATE-----** and **-----END CERTIFICATE-----**.

The file downloaded in step 1 is DER encoded, so we want to convert to PEM encoding for the ESP8266.  To do this we will use the OpenSSL software you installed as part of the [prerequisites](../part1/PREREQ.md){target=_blank}

- In a command or terminal window navigate to the directory containing the downloaded USERTrustRSAAddTrustCA.crt file
- run the command ```openssl x509 -inform der -in USERTrustRSAAddTrustCA.crt -out USERTrustRSAAddTrustCA.pem```

### Step 3 - Adding the root CA certificate to the ESP8266

To allow the ESP8266 to validate the server certificate you need to add the root CA certificate to the ESP8266.  The USERTrustRSAAddTrustCA.pem needs to be added to a directory called data in the sketch directory.  You can find out where the sketch directory is by using the *sketch* -> *Show sketch folder* in the Arduino menu.  Inside the sketch directory create a new directory called **data** then copy the USERTrustRSAAddTrustCA.pem file into the data directory.  You added the data upload tool to the Arduino IDE as part of the prerequisite setup instructions, so you can now run the tool.  Before running the data upload tool ensure the Serial Monitor window is closed, as it will block communication between the device and upload tool.  From the top menu select *Tools* -> *ESP8266 LittleFS Data Upload*

### Step 4 - Updating the ESP8266 code to use the certificate to establish a secure connection

When a server connects using SSL/TLS it presents its own certificate for verification.  The client uses its local CA certificate store to validate the certificate presented by the server is authentic, by validating that a known CA signed the certificate.

Part of the certificate verification process checks that the certificate is in data (not before the start time of the certificate and not after certificate expiry time), so the ESP8266 needs to know the correct date/time.  The Network Time Protocol can be used to get the correct time from Internet servers.

You have already uploaded the CA certificate to the ESP8266, so now the code needs to be updated to load the certificate from the flash file system and switch to using a SSL/TLS connection.

Make the following code changes, modifying the TZ_OFFSET and TZ_DST values to represent your local timezone shift (in hours) from Greenwich Mean Time (GMT/UTC) and daylight savings time shift (in minutes):

- Add an include at the top of the file to access the file system : `#include <LittleFS.h>`
- Add an include after the **ESP8266WiFi.h** include to add time : `#include <time.h>`
- Change the MQTT_PORT to use the secure port 8883 : `#define MQTT_PORT 8883`
- Add a new #define to name the CA certificate : `#define CA_CERT_FILE "/USERTrustRSAAddTrustCA.pem"`
- Change the wifiClient to use the secure version : `BearSSL::WiFiClientSecure wifiClient;`
- Add a new variable definition below the mqtt variable definition : `BearSSL::X509List *rootCert;`
- Add #define to set timezone offset : `#define TZ_OFFSET -5  //Hours timezone offset to GMT (without daylight saving time)`
- Add #define to set day light saving offset : `#define TZ_DST    60  //Minutes timezone offset for Daylight saving`

- Modify the MQTT connection code in the setup() function to establish a secure connection:

```C++
  char *ca_cert = nullptr;
  
  // Get certs from file system and load into WiFiSecure client
  LittleFS.begin();
  File ca = LittleFS.open(CA_CERT_FILE, "r");
  if(!ca) {
    Serial.println("Couldn't load CA cert");
  } else {
    size_t certSize = ca.size();
    ca_cert = (char *)malloc(certSize);
    if (certSize != ca.readBytes(ca_cert, certSize)) {
      Serial.println("Loading CA cert failed");
    } else {
      Serial.println("Loaded CA cert");
      rootCert = new BearSSL::X509List(ca_cert);
      wifiClient.setTrustAnchors(rootCert);
    }
    free(ca_cert);
    ca.close();
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

  // Connect to MQTT
  while(! mqtt.connected()){
    if (mqtt.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_TOKEN)) {
      Serial.println("MQTT Connected");
      mqtt.subscribe(MQTT_TOPIC_DISPLAY);
    } else {
      Serial.print("last SSL Error = ");
      Serial.print(wifiClient.getLastSSLError(msg, 50));
      Serial.print(" : ");
      Serial.println(msg);
      Serial.println("MQTT Failed to connect! ... retrying");
      delay(500);
    }
  }
```

### Step 5 - How the LittleFS file system works

The ESP8266 allows some of the on board or connected flash memory to be used as a file system.  The Arduino IDE plugin allows you to customise the size of the filesystem (*Tools* -> *Flash Size* allows you to specify 1MB or 3MB for the file system when a NodeMCU board is the target device).  The LittleFS filesystem is a very simple file system.  Filenames should not be more than 31 characters.

The data upload tool allows the content data directory in the sketch folder to be converted to a LittleFS filesystem and uploaded to the device, where the content can then be access from the application.

The LittleFS filesystem is included in a sketch by including the appropriate header: `#include <LittleFS.h>` then it is initialised with a **LittleFS.begin()** function call.

The application code opens up the certificate files using the **open()** function and specifying to only allow read operations.  The **WiFiClientSecure** can load the certificates from the open File handles using the **load()** functions.

When you have finished with a file it can be closed with the **close()** function.

Further details and the full API can be seen in the [documentation](https://arduino-esp8266.readthedocs.io/en/2.7.4_a/filesystem.html){target=_blank}

### Solution code

The finished application should look like this:

```C++
#include <LittleFS.h>
#include <ESP8266WiFi.h>
#include <time.h>
#include <Adafruit_NeoPixel.h>
#include <DHT.h>
#include <ArduinoJson.h>
#include <PubSubClient.h>

// --------------------------------------------------------------------------------------------
//        UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT
// --------------------------------------------------------------------------------------------

// MQTT connection details
#define MQTT_HOST "hostname.rmq.cloudamqp.com"
#define MQTT_PORT 8883
#define MQTT_CLIENT_ID "dev01"
#define MQTT_USER "abcdezgf:abcdezgf"
#define MQTT_TOKEN "abxyz-jhdjdhfjkskhdjfSQNeH2pq9s_UlGy"
#define MQTT_TOPIC "dev01/status"
#define MQTT_TOPIC_DISPLAY "dev01/display"
#define CA_CERT_FILE "/USERTrustRSAAddTrustCA.pem"

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
BearSSL::WiFiClientSecure wifiClient;
PubSubClient mqtt(MQTT_HOST, MQTT_PORT, callback, wifiClient);

BearSSL::X509List *rootCert;

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
  char *ca_cert = nullptr;

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
  LittleFS.begin();
  File ca = LittleFS.open(CA_CERT_FILE, "r");
  if(!ca) {
    Serial.println("Couldn't load CA cert");
  } else {
    size_t certSize = ca.size();
    ca_cert = (char *)malloc(certSize);
    if (certSize != ca.readBytes(ca_cert, certSize)) {
      Serial.println("Loading CA cert failed");
    } else {
      Serial.println("Loaded CA cert");
      rootCert = new BearSSL::X509List(ca_cert);
      wifiClient.setTrustAnchors(rootCert);
    }
    free(ca_cert);
    ca.close();
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

  // Connect to MQTT
   while(! mqtt.connected()){
    if (mqtt.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_TOKEN)) { // Token Authentication
      Serial.println("MQTT Connected");
      mqtt.subscribe(MQTT_TOPIC_DISPLAY);
    } else {
      Serial.print("last SSL Error = ");
      Serial.print(wifiClient.getLastSSLError(msg, 50));
      Serial.print(" : ");
      Serial.println(msg);
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
    if (mqtt.connect(MQTT_CLIENT_ID, MQTT_USER, MQTT_TOKEN)) {
      Serial.println("MQTT Connected");
     mqtt.subscribe(MQTT_TOPIC_DISPLAY);
      mqtt.loop();
    } else {
      Serial.print("last SSL Error = ");
      Serial.print(wifiClient.getLastSSLError(msg, 50));
      Serial.print(" : ");
      Serial.println(msg);
      Serial.println("MQTT Failed to connect! ... retrying");
      delay(500);
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

    // Publish data to MQTT
    status["tmp"] = t;
    status["hmdty"] = h;
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
