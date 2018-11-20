*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](../part1/README.md) - [Parte 2](../part2/README.md) - [Parte 3](../part3/README.md) - [Parte 4](../part4/README.md)
***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***

# Criando o aplicativo de detecção para o ESP8266

## Objetivos

Neste laboratório, você reunirá todas as informações da parte 1 em um único aplicativo. Você vai aprender:

- Como criar um novo esboço e algumas recomendações para a estrutura do aplicativo
- Como combinar as bibliotecas WiFi, neopixel e DHT em um único aplicativo
- Como trabalhar com dados JSON no ESP8266

### Introdução

Na parte 1, você examinou vários esboços de exemplo para ver como os sensores WiFi, NeoPixel LED e DHT funcionam com o Arduino. Agora você criará um aplicativo que combina todos os recursos e, enquanto trabalhamos no restante desta parte, você conectará o dispositivo à plataforma IoT e adicionará um código para enviar dados para a plataforma e receber comandos da plataforma. Inicialmente, você usará conexões MQTT não seguras e, no final desta seção, adicionará SSL / TLS e verificação de certificado para proteger a comunicação.

### Etapa 1 - Criando um novo sketch

Crie um novo esboço no Arduino IDE usando *Arquivo* -> *Novo* ou o ícone na barra de ferramentas. Salve o sketch *Arquivo* -> *Salvar* e nomeie o sketch, nome sugerido **esp8266Workshop**.

Você precisa adicionar mais 1 biblioteca ao Arduino IDE para fornecer funções para manipular o formato de dados JSON. Quando começarmos a enviar e receber dados da IoT Platform, o formato de dados JSON será usado, para que possamos começar a usar o JSON agora. No Gerenciador de bibliotecas (*Sketch* -> *Gereciador de Bibliotecas* -> *Gerenciar Bibliotecas ...*) pesquise **ArduinoJson** e instale a versão mais recente da biblioteca v5.x.

**Note, não use versões beta da biblioteca ArduinoJson, siga as versões mais recentes da versão v5.x. Você pode usar o menu suspenso no gerenciador de bibliotecas para selecionar a versão da biblioteca a ser instalada. Se você instalou o v6 beta, use o gerenciador de bibliotecas para substituir a versão pelo release 5.x.x mais recente da biblioteca. Você receberá um erro de compilação se usar a v6 com o código do bootcamp.**

### Etapa 2 - Insira o código do aplicativo

Eu forneci o código para o aplicativo abaixo. Quando você inseri-lo (ou recortá-lo e colá-lo), reserve um tempo para garantir que você entende o aplicativo e o que cada uma das chamadas de função da biblioteca faz.

Adicione o código abaixo ao esboço acima da função **setup()**:

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

O código acima isola toda a configuração que pode ser alterada. Eu prefiro colocar toda a configuração na frente de um aplicativo, por isso é fácil de atualizar conforme necessário. Você precisará atualizar o SSID ea senha do WiFI para a rede WiFi à qual deseja se conectar. Isso deve estar disponível no local em que você está trabalhando.

Adicione o seguinte código a função **setup()** :

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

Esta função inicializa a porta Serial, a conexão WiFi, o LED e o sensor DHT.

A função loop deve conter:

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

TEste código é chamado repetidamente após a função **setup()** returns.  Ele lê a umidade e a temperatura do sensor DHT, valida o recebimento das leituras e depois define a cor do LED para a cor correta com base na temperatura e nas temperaturas de alerta e aviso definidas nas constantes na parte superior do aplicativo. Finalmente, os valores de temperatura e umidade são adicionados ao objeto JSON, que é então convertido em um buffer de seqüência de caracteres e impresso no console.

### Etapa 3 - Execute o código e visualize a saída usando o Monitor Serial

Salve, compile e envie o esboço. Uma vez carregado, abra o Monitor Serial e defina a taxa de transmissão para 115200, para corresponder à taxa definida na mensagem Serial.begin (115200). Você deverá ver a confirmação de que a conexão WiFi foi feita e, em seguida, deverá ver os dados do sensor formatados como uma string JSON, repetindo a cada 10 segundos (10000 milissegundos).

O LED também deve ser definido para uma cor baseada na temperatura e as constantes WARN e ALARM definidas na parte superior do sketch:

- AZUL (baixo ALARM_COLD)
- TURQUESA (entre ALARM_COLD e WARM_COLD)
- VERDE (entre WARN_COLD e WARN_HOT)
- AMARELO (between WARN_HOT e ALARM_HOT)
- VERMELHO (above ALARM_HOT)

### Etapa 4 - Entendendo como trabalhar com dados JSON

O formato JSON é amplamente usado para APIs e troca de dados entre sistemas. O esboço acima usa uma das bibliotecas JSON otimizadas para pequenos dispositivos de memória. Para usar a biblioteca, você precisa:

1. Inicialize a biblioteca e aloque alguma memória para a biblioteca trabalhar com : `StaticJsonBuffer<100> jsonBuffer;`
2. Crie um novo objeto JSON vazio : `JsonObject& payload = jsonBuffer.createObject();`
3. Adicione propriedades requeridas usando uma das funções disponíveis:

    ```C++
    JsonObject& status = payload.createNestedObject("d");
    status["temp"] = t;
    status["humidity"] = h;
    ```

A função **printTo()**  converte o objeto JSON em uma string e o grava no buffer fornecido, para que possa ser usado como uma string c.

Veja a biblioteca [documentação](https://arduinojson.org/?utm_source=meta&utm_medium=library.properties) para mais informações

***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***
*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](../part1/README.md) - [Parte 2](../part2/README.md) - [Parte 3](../part3/README.md) - [Parte 4](../part4/README.md)
