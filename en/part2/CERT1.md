*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
***
**Part 2** - [Device Registration](DEVICE.md) - [Application](APP.md) - [MQTT](MQTT.md) - [**Server Certificate**](CERT1.md) - [Client Certificate](CERT2.md)
***

# Adding secure communication between the device and IoT Platform using SSL/TLS

## Lab Objectives

In this Lab you will modify MQTT to use a secure connection.  You will learn:

- How to add SSL/TLS capability to the network connection that MQTT uses
- How to generate certificates to enable secure connections using OpenSSL
- How to add the certificates to the IBM Watson IoT Platform
- How to add the certificate to the ESP8266 using part of the flash memory as a file system
- Basic operations of the SPIFFS file system

## Introduction

Having unsecured traffic for an IoT solution is not a good idea, so in this lab you will convert the unsecured MQTT connection into a SSL/TLS connection.

When using SSL/TLS you can verify the certificate(s) presented by the server if you have the certificate of the Root Certificate Authority used to sign the server certificate.  Your Laptop will have common root CA certificates installed as part of the OS or browser so web traffic can be secured and the padlock on your browser can be shown.  However, you need to add any certificate to IoT devices if you want to verify server certificates.

The Watson IoT platform does allow you to replace the certificates used for MQTT traffic, so in this exercise you will generate your own self-signed certificates, add them to the Watson IoT platform and the ESP8266 code, to enable a SSL/TLS connection with the server certificate verified against the root CA certificate installed on the ESP8266.

The platform [documentation](https://console.bluemix.net/docs/services/IoT/reference/security/set_up_certificates.html#set_up_certificates) provides information about what information must be contained in certificates to work with the platform.

In the prerequisite section you installed the OpenSSL tool, which allows you to work with certificates.  I have provided 2 configuration files in the [certificates](/certificates) folder of this git repo. You need to download them and have them in the directory you will use to generate the certificates.  If you have cloned or downloaded the repo, then I suggest you work in the certificates directory.

The commands are provided to create text (pem) and binary (der) formats of the keys and certificates, as some device libraries require one or the other format.  In this workshop we will only use the text versions of the certificates and keys.

### Step 1 - Generating a root Certificate Authority Key and Certificate

You will start by generating a root CA key and certificate.  This will then be used to sign a server certificate.

In a command windows enter the following commands, you need to replace some values, so do not just copy and paste the commands as shown, or your certificates will not work!

*Note for Windows users: If you opted for the openssl windows binary install and didn't add the bin directory to your path, then you will need to use the full path to the openssl binary e.g. `c:\OpenSSL-Win64\bin\openssl` in the commands below.  Also you do not have access to the xxd command, so cannot run the xxd commands shown, but the generated header file is not needed for this workshop.*

```bash
openssl genrsa -aes256 -passout pass:password123 -out rootCA_key.pem 2048

openssl req -new -sha256 -x509 -days 3560 -subj "/C=GB/ST=DOR/L=Bournemouth/O=z53u40/OU=z53u40 Corporate/CN=z53u40 Root CA" -extensions v3_ca -set_serial 1 -passin pass:password123 -key rootCA_key.pem -out rootCA_certificate.pem -config ext.cfg

openssl x509 -outform der -in rootCA_certificate.pem -out rootCA_certificate.der

xxd -i rootCA_certificate.der rootCA_certificate.der.h
```

replacing:

- C=GB : GB is an ISO alpha-2 country code , so use your own country (CA=Canada, US=USA, .....).  You can find a list of valid ISO alpha-2 country codes [here](https://en.wikipedia.org/wiki/ISO_3166-1#Current_codes)
- ST=DOR : DOR is an English county, replace with appropriate state/county/region
- L=Bournemouth : Bournemouth is an English town, replace with appropriate location
- O=z53u40 : z53u40 is the Organisation ID for my IoT Platform
- OU=z53u40 Corporate : z53u40 is the Organisation ID for my IoT Platform
- CN=z53u40 Root CA : z53u40 is the Organisation ID for my IoT Platform
- pass:password123 : password123 is the password that will protect the key - if you change this value do not forget what you entered, as you need it when using the key later.

*Note: If you get an error similar to ```Can't load /home/xxx/.rnd into RNG```, you can ignore it.  It just indicates that this is the first time you have used the random number generator.*

This generates the key and protects it with a password.  A public certificate is then generated in pem format, which is then converted to der format.  Finally the xxd command creates a header file which allows the certificate to be embedded in code - this can be useful for devices that don't have a file system.

### Step 2 - Uploading the root CA Certificate to the IoT Platform

You need to load the root CA certificate into the IoT platform using the console.  In the settings section goto to CA Certificates in the Security section.  Select to **Add certificate** then select the rootCA_certificate.pem file you just generated to upload to the platform, then press **Save**.

### Step 3 - Generating a Server key and certificate

Now you have a Root Certificate Authority key and certificate, they can be used to sign other certificates that can be verified using the root CA certificate.

You need to edit file [srvext.cfg](/certificates/srvext.cfg), which you should have retrieved from the certificates folder in this git repo.  You need to change the **subjectAltName** entry to match the DNS entry of your instance of the Watson IoT platform, so change the host part of the URL to your Organisation Id:

`subjectAltName = DNS:z53u40.messaging.internetofthings.ibmcloud.com`

To generate a certificate for the IoT platform to use run the following commands:

```bash
openssl genrsa -aes256 -passout pass:password123 -out mqttServer_key.pem 2048

openssl req -new -sha256 -subj "/C=GB/ST=DOR/L=Bournemouth/O=z53u40/OU=z53u40/CN=z53u40.messaging.internetofthings.ibmcloud.com" -passin pass:password123 -key mqttServer_key.pem -out mqttServer_crt.csr

openssl x509 -days 3560 -in mqttServer_crt.csr -out mqttServer_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -extensions v3_req -extfile srvext.cfg -set_serial 11

openssl x509 -outform der -in mqttServer_crt.pem -out mqttServer_crt.der

xxd -i mqttServer_crt.der mqttServer_crt.der.h
```

again substituting values for C=, ST=, L=, O=, OU= and CN=, but this time it is important that the CN value is the URL of your instance of the IoT messaging URL, which is the Organisation ID followed by **.messaging.internetofthings.ibmcloud.com**, which should also match the **subjectAltName** field in the [srvext.cfg](/certificates/srvext.cfg) file.

The commands above generate a new key for the server, creates a certificate request for the server, issues the certificate and signs it with the root CA key, saving it as a pem file.  The certificate is converted from pem to der format and lastly the xxd command creates a header file to embed the certificate in code.

### Step 4 - Add the server certificate to the IoT Platform

Now you have the server certificate you can upload to the IoT platform in the settings section of the console in the Messaging Server Certificates section under Security.  Select to **Add Certificate** then upload the certificate (mqttServer_crt.pem) and private key (mqttServer_key.pem).  You need to also provide the password you provided when creating the key (password123).  Once the certificate is uploaded you enable it by setting the Currently Active Certificate to your key.

Your can test the server certificate by using openssl:

``` bash
openssl s_client -CAfile <CA certificate pem file> -showcerts -state  -servername <org ID>.messaging.internetofthings.ibmcloud.com -connect <org ID>.messaging.internetofthings.ibmcloud.com:8883
```

replace <CA certificate pem file> with the name of the CA root certificate and <org ID> with the 6 character org ID for your instance of the IOT Platform.

### Step 5 - Adding the root CA certificate to the ESP8266

To allow the ESP8266 to validate the server certificate you need to add the root CA certificate to the ESP8266.  The rootCA_certificate.pem needs to be added to a directory called data in the sketch directory.  You can find out where the sketch directory is by using the *sketch* -> *Show sketch folder* in the Arduino menu.  Inside the sketch directory create a new directory called **data** then copy the rootCA_certificate.pem file into the data directory.  You added the data upload tool to the Arduino IDE as part of the prerequisite setup instructions, so you can now run the tool.  Before running the data upload tool ensure the Serial Monitor window is closed, as it will block communication between the device and upload tool.  From the top menu select *Tools* -> *ESP8266 Sketch Data Upload*

### Step 6 - Adding the root CA certificate to your OS or browser

Finally you need to add the root CA certificate to your OS or browser, as the IoT Platform console uses a secure connection to get data required to populate and update the console in your browser.  If you don't add the root CA Certificate then the console will not show any data.

If using Firefox you need to import the rootCA_certificate.pem file, by accessing the security section of the preferences.  On some platform there is an Advanced option before you are able to view certificates, then there is an option to import certificates then trust to identify web sites.

If using Chrome it depends on the platform.  On some platforms Chrome uses the system certificates, but on others it manages its own certificates and then like Firefox you need to go into the security settings to import the certificate authority certificate and trust it to identify web sites.

To add the root CA certificate to OS:

- **Linux**: Many browsers on Linux do not use the OS certificates but manage their own certificate store, so check before adding the certificate to the OS store.  If you do need to add the rootCA certificate to the OS ca certificate store, then unfortunately there is not a standard way on Linux to achieve this.  Each distro has a slightly different approach, but many want the certificate to be a .crt file, so use the following command to convert the .pem to .crt: `openssl x509 -outform der -in rootCA_certificate.pem -out rootCA_certificate.crt`
  - Debian: With admin privileges copy the rootCA_certificate.crt file to /usr/share/ca-certificates then run `dpkg-reconfigure ca-certificates`
  - Fedora: Copy the rootCA_certificate.pem file to **/etc/pki/ca-trust/source/anchors/** (using sudo mv or other root access) then run command `update-ca-trust extract` with admin privileges.
  - Ubuntu: Copy the rootCA_certificate.crt to **/usr/local/share/ca-certificates** using admin privileges then run `update-ca-certificates`.
- **MacOS**: Double click the certificate in Finder to open it in the Keychain Access app.  It will automatically show as not trusted.  Double click it to open up the certificate details window and then expand the **Trust** section.  Change the SSL value to **Always Trust**.  Close the certificate window (you will be prompted for your account password to verify the change).
- **Windows**: Launch the Microsoft Management Console (enter mmc in the start menu), then select *File* ->* Add/Remove Snap-in...*. Highlight Certificates and press **Add**.  Select to manage certificates for **Computer account**, **Local computer** then press **Finish** then **OK**.  Back in the mmc, select the Certificates item in the left column then right-click the **Trusted Root Certificate Authorities** item.  From the popup menu select *All Tasks* -> *Import...* to launch the Certificate Import Wizard.  Select the rootCA_certificate pem or der file (may need to alter filter to show all files) and place it in the **Trusted Root Certificate Authorities** store.

**Note** : *If you are adding a certificate to a browser certificate manager, please ensure you are adding a Certificate Authority certificate.  This should allow you to import a .pem or .der file.  If it is asking for a .p12 file then you are trying to import a certificate and key, so are in the wrong section of the certificate manager.  You want to be adding a **Certificate Authority** certificate or certificate chain.*

### Step 7 - Updating the ESP8266 code to use the certificate to establish a secure connection

When a server connects using SSL/TLS it presents its own certificate for verification.  The client uses its local CA certificate store to validate the certificate presented by the server is authentic, by validating that a known CA signed the certificate.

Part of the certificate verification process checks that the certificate is in data (not before the start time of the certificate and not after certificate expiry time), so the ESP8266 needs to know the correct date/time.  The Network Time Protocol can be used to get the correct time from Internet servers.

You have already uploaded the CA certificate to the ESP8266, so now the code needs to be updated to load the certificate from the flash file system and switch to using a SSL/TLS connection.

Make the following code changes:

- Add an include at the top of the file to access the file system : `#include <FS.h>`
- Add an include after the **ESP8266WiFi.h** include to add time : `#include <time.h>`
- Change the MQTT_PORT to use the secure port 8883 : `#define MQTT_PORT 8883`
- Add a new #define to name the CA certificate : `#define CA_CERT_FILE "/rootCA_certificate.pem"`
- Change the wifiClient to use the secure version : `BearSSL::WiFiClientSecure wifiClient;`
- Add a new variable definition below the mqtt variable definition : `char *ca_cert;`
- Add #define to set timezone offset : `#define TZ_OFFSET -5  //Hours timezone offset to GMT (without daylight saving time)`
- Add #define to set day light saving offset : `#define TZ_DST    60  //Minutes timezone offset for Daylight saving`

- Modify the MQTT connection code in the setup() function to establish a secure connection:

```C++
  // Get certs from file system and load into WiFiSecure client
  SPIFFS.begin();
  File ca = SPIFFS.open(CA_CERT_FILE, "r");
  if(!ca) {
    Serial.println("Couldn't load CA cert");
  } else {
    size_t certSize = ca.size();
    ca_cert = (char *)malloc(certSize);
    if (certSize != ca.readBytes(ca_cert, certSize)) {
      Serial.println("Loading CA cert failed");
    } else {
      Serial.println("Loaded CA cert");
    }
    ca.close();
  }

  //Set the cert(s) in the WiFi client
  BearSSL::X509List rootCert(ca_cert);
  wifiClient.setTrustAnchors(&rootCert);

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
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
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

Save, compile and upload the code and now you should have a secure connection.  If you look at the IoT Platform console, in the devices section you should now see the connection state, in the Identity section when selecting the device, is connected with **SecureToken**.  Previous the status would have shown **Insecure**.

You should now go into the IoT Platform settings section and update the connection security policy from **TLS Optional** to **TLS with Token Authentication** then **Save** the change.

### Step 8 - How the SPIFFS file system works

The ESP8266 allows some of the on board or connected flash memory to be used as a file system.  The Arduino IDE plugin allows you to customise the size of the filesystem (*Tools* -> *Flash Size* allows you to specify 1MB or 3MB for the file system when a NodeMCU board is the target device).  The SPIFFS filesystem is a very simple file system, which does not support directories.  It is a flat list of files, however, the filenames can include the '/' character to give a sense of directory structure.  Filenames should not be more than 31 characters.

The data upload tool allows the content data directory in the sketch folder to be converted to a SPIFFS filesystem and uploaded to the device, where the content can then be access from the application.

The SPIFFS filesystem is included in a sketch by including the appropriate header: `#include <FS.h>` then it is initialised with a **SPIFFS.begin()** function call.

The application code opens up the certificate files using the **open()** function and specifying to only allow read operations.  The **WiFiClientSecure** can load the certificates from the open File handles using the **load()** functions.

When you have finished with a file it can be closed with the **close()** function.

Further details and the full API can be seen in the [documentation](https://arduino-esp8266.readthedocs.io/en/2.4.1/filesystem.html)

### Solution code

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
#define CA_CERT_FILE "/rootCA_certificate.pem"

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

char *ca_cert;

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
    size_t certSize = ca.size();
    ca_cert = (char *)malloc(certSize);
    if (certSize != ca.readBytes(ca_cert, certSize)) {
      Serial.println("Loading CA cert failed");
    } else {
      Serial.println("Loaded CA cert");
    }
    ca.close();
  }

  //Set the cert(s) in the WiFi client
  BearSSL::X509List rootCert(ca_cert);
  wifiClient.setTrustAnchors(&rootCert);

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
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
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
**Part 2** - [Device Registration](DEVICE.md) - [Application](APP.md) - [MQTT](MQTT.md) - [**Server Certificate**](CERT1.md) - [Client Certificate](CERT2.md)
***
*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
