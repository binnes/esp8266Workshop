*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***

# Usando um certificado de dispositivo para autenticar na plataforma Watson IoT

## Objetivos

Neste laboratório, você estenderá o aplicativo ativando os certificados do lado do cliente. Você vai aprender como:

- Gere chaves e certificados do clientes
- Modifique o aplicativo para usar os certificados do cliente
- Configurar a política de conexão da plataforma IoT para exigir tokens e / ou certificados

### Etapa 1 - Gerando a chave e o certificado para um dispositivo

A ferramenta openssl deve ser usada para gerar a chave e o certificado, como no laboratório anterior. Você precisa trabalhar no mesmo diretório que no laboratório anterior, pois os comandos abaixo precisam de acesso ao arquivo rootCA_certificate.pem. Se você alterou a senha da chave da CA raiz, lembre-se de alterar o valor nos comandos mostrados abaixo:

```bash
openssl genrsa -aes256 -passout pass:password123 -out SecuredDev01_key.pem 2048

openssl req -new -sha256 -days 3560 -subj "/C=GB/ST=DOR/L=Bournemouth/O=z53u40/OU=z53u40 Corporate/CN=d:ESP8266:dev01" -passin pass:password123 -key SecuredDev01_key.pem -out SecuredDev01_crt.csr

openssl x509 -days 3650 -in SecuredDev01_crt.csr -out SecuredDev01_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -set_serial 131

openssl rsa -outform der -in SecuredDev01_key.pem -passin pass:password123 -out SecuredDev01_key.key

openssl x509 -outform der -in SecuredDev01_crt.pem -out SecuredDev01_crt.der
```

### Passo 2 - Carregar o certificado e chave para o dispositivo ESP8266

É necessário adicionar a chave privada (SecuredDev01_key.key) e o certificado (SecuredDev01_crt.der) à pasta de dados dentro da pasta de rascunho, em seguida, executar a ferramenta de upload de dados (* Ferramentas * -> * ESP8266 Sketch Data Upload *) para instalar o certificados no sistema de arquivos do dispositivo.

### Etapa 3 - Modifique o aplicativo para usar o certificado e a chave do cliente

Agora você pode modificar o código para carregar os certificados e adicioná-los à conexão:

Adicione duas instruções #define de modo contendo os nomes da chave e do certificado:

```C++
#define KEY_FILE "/SecuredDev01_key.key"
#define CERT_FILE "/SecuredDev01_crt.der"
```

em seguida, atualize o código dentro da função setup () para carregar a chave e o certificado adicionais:

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

### Etapa 4 - Execute o aplicativo

Salve, compile e envie o esboço para o dispositivo e verifique se o dispositivo está conectado.

### Etapa 5 - Configurar a política de segurança na plataforma IoT

Agora você tem certificados de cliente trabalhando com o dispositivo, e agora pode escolher como deseja que os dispositivos sejam verificados. Se você abrir o console da IoT Platform e acessar a seção de configurações, a seção Segurança de conexão e a Política de segurança de conexão aberta, verá que há várias opções:

- TLS Opcional
- TLS com autenticação de token
- TLS com autenticação de certificado de cliente
- TLS com certificado de cliente e autenticação de token
- TLS com certificado de cliente ou autenticação de token

Agora você pode decidir qual política deseja. Se você não quiser usar a autenticação de token, altere a chamada de função **connect()** e omita as informações do usuário e do token:
- com autenticação por token : `if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {`
- sem autenticação por token: `if (mqtt.connect(MQTT_DEVICEID)) {`

Você também verá que pode criar regras personalizadas além da regra padrão. Isso permite que diferentes tipos de dispositivos tenham uma política diferente. Se um tipo de dispositivo não corresponder a uma regra personalizada, a regra padrão será usada.

### Código da solução

A aplicação finalizada deve ficar assim:

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
#define MQTT_TOPIC_CMD "iot-2/cmd/display/fmt/json"
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
      mqtt.subscribe(MQTT_TOPIC_CMD);
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
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***
*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)