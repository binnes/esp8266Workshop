*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***

# Connecting Device to the Watson IoT Platform using MQTT

## Objetivos

In this lab you will learn how to add MQTT messaging to an application. You will learn:

- How to connect to a MQTT broker using unsecured connection
- How to use MQTT to connect to the Watson IoT platform

### Introdução

No laboratório anterior, você construiu o aplicativo de sensor autônomo. Agora, queremos torná-lo um aplicativo do Internet of Things, adicionando o MQTT para enviar os dados para a plataforma IoT.

Começaremos usando uma conexão MQTT não segura e, na próxima seção, protegeremos a conexão. No entanto, a plataforma Watson IoT é configurada para bloquear todas as conexões não seguras por padrão, portanto, é necessário configurar sua instância do Watson IoT para permitir a conexão não segura.

### Etapa 1 - Configurar a plataforma Watson IoT para permitir conexões não seguras

Abra o console da plataforma IoT para a instância conectada ao seu aplicativo Boilerplate. No painel (* ≡ * -> * Dashboard *), selecione o aplicativo e, na seção de visão geral, selecione a plataforma IoT no painel de conexões).

Inicie o console da plataforma IoT e, em seguida, alterne para a seção Configurações. Em Segurança, selecione Segurança da conexão e, em seguida, pressione o botão **Política de segurança de conexão aberta**. Altere o Nível de segurança padrão para **TLS Opcional**, aceite a mensagem de aviso pressionando o botão Ok e, em seguida, **Salvar** a alteração. Sua instância da plataforma IoT agora aceitará conexões MQTT não seguras. Deixe a janela do navegador mostrando o console da IoT Platform aberto, pois você precisará obter algumas informações ao adicionar o código MQTT ao aplicativo ESP8266.

### Etapa 2 - Aprimorando o aplicativo para enviar dados para a plataforma IoT

No Arduino IDE, você precisa adicionar o código MQTT, mas antes de adicionar o código MQTT, é necessário instalar a biblioteca. No gerenciador da biblioteca (* Sketch * -> * Include Library * -> * Manage Libraries ... *) procure e instale o PubSubClient. Em seguida, adicione a inclusão à parte superior do aplicativo, abaixo dos arquivos de inclusão existentes

`#include <PubSubClient.h>`

Agora adicione algumas instruções #define para conter o código MQTT. Adicione estes sob o comentário **UPDATE CONFIGURATION TO MATCH YOUR ENVIRONMENT**:

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

Você precisa alterar os valores para corresponder à sua configuração:

- XXXXXX deve ser o ID da organização com 6 caracteres para sua plataforma. Se você olhar na seção de configurações do console da IoT Platform, em identidade, você verá o valor que precisa usar.
- AAAA é o tipo de dispositivo que você usou para o dispositivo ESP8266. Isso deve ser ESP8266, mas você pode verificar procurando na seção de dispositivos. Todos os dispositivos registrados estão listados aqui e você pode ver o tipo de dispositivo e o ID do dispositivo.

- ZZZZ é o ID do dispositivo para o seu ESP8266, no laboratório foi sugerido para usar dev01
- PPPPP é o token que você usou quando registrou o dispositivo (espero que você não tenha esquecido o que você usou, então se você precisar apagar o dispositivo e registrá-lo novamente)

Após o bloco de configuração e sob as declarações de variáveis pixel e dht, você precisa adicionar o seguinte:

```C++
// MQTT objects
void callback(char* topic, byte* payload, unsigned int length);
WiFiClient wifiClient;
PubSubClient mqtt(MQTT_HOST, MQTT_PORT, callback, wifiClient);
```

Acima da função setup (), adicione a implementação da função de retorno de chamada. Isso é chamado sempre que uma mensagem MQTT é enviada ao dispositivo. Por enquanto, apenas imprime uma mensagem para o console serial:

```C++
void callback(char* topic, byte* payload, unsigned int length) {
  // handle message arrived
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.println("] ");
}
```

no final da função setup (), inclua o seguinte código para conectar o cliente MQTT à Plataforma IoT:

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

no topo da função loop () adicione o seguinte código para verificar se a conexão mqtt ainda é válida e chame a função mqtt.loop () para processar qualquer mensagem pendente:

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
Por fim, adicione o código para enviar os dados para a plataforma IoT. Nós já temos os dados formatados como uma string JSON, para que possamos agora adicionar o seguinte código depois que ele for impresso no console na função ** loop () **:

```C++
    Serial.println(msg);
    if (!mqtt.publish(MQTT_TOPIC, msg)) {
      Serial.println("MQTT Publish failed");
    }
```

Finalmente, substitua o segundo `` `delay (10000)` `` para chamar a função mqtt ** loop () **, assim o programa processa as mensagens recebidas:

```C++
  // Pause - but keep polling MQTT for incoming messages
  for (int i = 0; i < 10; i++) {
    mqtt.loop();
    delay(1000);
  }
```

### Etapa 3 - Execute o aplicativo

Compile e envie o código para o seu ESP8266 e você deverá ver o  ```WiFi Connected```, Seguido por ```Attempting MQTT connection...MQTT Connected```. A cada intervalo de 10 segundos você vê os dados do sensor DHT impressos no console. O ESP8266 também deve publicar mensagens MQTT para o Watson IoT Platform. Para verificar isso, alterne para a janela do navegador que mostra o console da IoT Platform, alterne para a seção Dispositivos. Clique no dispositivo esp8266 para expandi-lo e clique em **Eventos Recentes**. Você deve ver as mensagens do evento de status com os dados ativos aparecendo a cada 10 segundos.

### Passo 4 - Como funciona

Ao conectar-se à plataforma Watson IoT, há alguns requisitos em alguns parâmetros usados durante a conexão.
A [documentação da plataforma](https://console.bluemix.net/docs/services/IoT/reference/security/connect_devices_apps_gw.html#connect_devices_apps_gw) oferece mais detalhes:

1. As instruções #define constroem os parâmetros requeridos:
   - host : < **org id** >.messaging.internetofthings.ibmcloud.com
   - ID do dispositivo : d:< **org id** >:< **device type** >:< **device id** >
   - topico para publicar dados : iot-2/evt/< **event id** >/fmt/<  **format string** >
   - topico para receber comandos : iot-2/cmd/< **command id** >/fmt/< **format string** >
2. Quando você inicializa o PubSubClient, você precisa passar o nome do host, a porta (1883 para conexões não seguras), uma função de retorno de chamada e uma conexão de rede. A função de retorno de chamada é chamada sempre que mensagens recebidas são recebidas.

3. Ligue para **connect()** para conectar-se à plataforma, passando o ID do dispositivo, um usuário, que é sempre o valor * use-token-auth * e o token escolhido ao registrar o dispositivo.

4. A função **subscribe()** registra a conexão para receber mensagens publicadas no tópico em questão.
5. O método **loop()** deve ser chamado regularmente para manter a conexão ativa e receber mensagens recebidas.
6. A função **publish()** envia dados sobre o tópico fornecido - *Nota*: Em alguns MQTT Clients, esta função somente enfileira a mensagem para envio. Na verdade, ela é enviada na função **loop()**.
7. Você pode verificar o status da conexão com a função **connected()**.

### Código da solução

 A aplicação completa do ESP8266 é mostrada abaixo (você precisará alterar a seção de configuração para corresponder ao seu ambiente):

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
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***
*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
