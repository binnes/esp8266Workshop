*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***

# Adicionando comunicação segura entre o dispositivo e a IoT Platform usando SSL / TLS

## Objetivos

Neste laboratório, você modificará o MQTT para usar uma conexão segura. Você vai aprender:

- Como adicionar o recurso SSL / TLS à conexão de rede que o MQTT usa
- Como gerar certificados para habilitar conexões seguras usando o OpenSSL
- Como adicionar os certificados ao IBM Watson IoT Platform
- Como adicionar o certificado ao ESP8266 usando parte da memória flash como um sistema de arquivos
- Operações básicas do sistema de arquivos SPIFFS

### Introdução

Ter tráfego não seguro para uma solução IoT não é uma boa ideia, portanto, neste laboratório, você converterá a conexão MQTT não segura em uma conexão SSL / TLS.

Ao usar SSL / TLS, você pode verificar o (s) certificado (s) apresentado (s) pelo servidor se tiver o certificado da Autoridade de Certificação Raiz usado para assinar o certificado do servidor. Seu laptop terá certificados comuns de CA raiz instalados como parte do sistema operacional ou do navegador, para que o tráfego da Web possa ser protegido e o cadeado no navegador possa ser exibido. No entanto, você precisa adicionar qualquer certificado aos dispositivos IoT se quiser verificar os certificados do servidor.

Existe uma limitação na biblioteca SSL / TLS fornecida no ambiente do Arduino como parte do plugin ESP8266. Essa biblioteca verificará um certificado do servidor, mas não se a cadeia de certificados contiver certificados intermediários. O certificado Watson IoT Platform está disponível em [nesta](https://console.bluemix.net/docs/services/IoT/reference/security/connect_devices_apps_gw.html#connect_devices_apps_gw) página, mas inclui uma cadeia de certificados, que a biblioteca ESP8266 não pode verificar.

A plataforma Watson IoT permite substituir os certificados usados para o tráfego MQTT, portanto, neste exercício, você gerará seus próprios certificados autoassinados, os adicionará à plataforma Watson IoT e ao código ESP8266, para habilitar uma conexão SSL / TLS com o certificado do servidor verificado em relação ao certificado da CA raiz instalado no ESP8266.

The platform [documentation](https://console.bluemix.net/docs/services/IoT/reference/security/set_up_certificates.html#set_up_certificates) provides information about what information must be contained in certificates to work with the platform.
Na seção de pré-requisitos, você instalou a ferramenta OpenSSL, que permite trabalhar com certificados. Eu forneci 2 arquivos de configuração nos [certificados](/certificates) pasta deste repositório git. Você precisa baixá-los e tê-los no diretório que você usará para gerar os certificados.  Se você clonou ou baixou o repositório, sugiro que trabalhe no diretório de certificados.

### Etapa 1 - Gerando uma chave e um certificado de autoridade de certificação raiz

Você começará gerando uma chave e um certificado da CA raiz. Isso será usado para assinar um certificado do servidor.

Em uma janela de comando do windows insira os seguintes comandos, você precisa substituir alguns valores, então não apenas copie e cole os comandos como mostrado, ou seus certificados não irão funcionar!

*Nota para usuários do Windows: Se você optou pela instalação binária do windows openssl e não adicionou o diretório bin ao seu caminho, então você precisará usar o caminho completo para o binário openssl, por exemplo. `c:/OpenSSL-Win64/bin/openssl` nos comandos abaixo. Além disso, você não tem acesso ao comando xxd, portanto, não pode executar os comandos xxd mostrados, mas o arquivo de cabeçalho gerado não é necessário para este workshop.*

```bash
openssl genrsa -aes256 -passout pass:password123 -out rootCA_key.pem 2048

openssl req -new -sha256 -x509 -days 3560 -subj "/C=GB/ST=DOR/L=Bournemouth/O=z53u40/OU=z53u40 Corporate/CN=z53u40 Root CA" -extensions v3_ca -set_serial 1 -passin pass:password123 -key rootCA_key.pem -out rootCA_certificate.pem -config ext.cfg

openssl x509 -outform der -in rootCA_certificate.pem -out rootCA_certificate.der

xxd -i rootCA_certificate.der rootCA_certificate.der.h
```

substituindo:

- C=GB : GB é um código de país, então use seu próprio país (CA=Canada, US=USA, .....)
- ST=DOR : DOR é um condado inglês, substituir com estado/condado/região apropriados
- L=Bournemouth : Bournemouth é uma cidade inglesa, substitua pela localização apropriada
- O=z53u40 : z53u40 é o ID da organização da minha plataforma IoT
- OU=z53u40 Organização : z53u40 é o ID da organização da minha plataforma IoT
- CN=z53u40 CA Raiz : z53u40 é o ID da organização da minha plataforma IoT
- pass:password123 : password123 é a senha que protegerá a chave - se você alterar esse valor, não esqueça o que você digitou, pois você precisa usá-la mais tarde.

Isso gera a chave e a protege com uma senha. Um certificado público é então gerado no formato pem, que é então convertido para o formato der. Finalmente, o comando xxd cria um arquivo de cabeçalho que permite que o certificado seja incorporado ao código - isso pode ser útil para dispositivos que não possuem um sistema de arquivos.

### Etapa 2 - Fazendo o upload do certificado da CA raiz para a plataforma IoT

Você precisa carregar o certificado da CA raiz na plataforma IoT usando o console. Na seção de configurações, vá para Certificados de autoridade de certificação na seção Segurança. Selecione para **Adicionar certificado** e selecione o arquivo rootCA_certificate.pem que acabou de gerar para fazer o upload para a plataforma e, em seguida, pressione **Salvar**.

### Etapa 3 - Gerando uma Chave e um Certificado do Servidor

Agora você tem uma chave e um certificado de autoridade de certificação raiz, eles podem ser usados para assinar outros certificados que podem ser verificados usando o certificado de CA raiz.

Você precisa editar o arquivo [srvext.cfg](/certificates/srvext.cfg), que você deve ter recuperado da pasta de certificados neste repositório git. Você precisa mudar o **subjectAltName** entrada para corresponder à entrada de DNS da sua instância da plataforma Watson IoT, por isso altere a parte do host do URL para o seu ID de organização:

`subjectAltName = DNS:z53u40.messaging.internetofthings.ibmcloud.com`

Para gerar um certificado para a plataforma IoT usar, execute os seguintes comandos:

```bash
openssl genrsa -aes256 -passout pass:password123 -out mqttServer_key.pem 2048

openssl req -new -sha256 -days 3560 -subj "/C=GB/ST=DOR/L=Bournemouth/O=z53u40/OU=z53u40/CN=z53u40.messaging.internetofthings.ibmcloud.com" -passin pass:password123 -key mqttServer_key.pem -out mqttServer_crt.csr

openssl x509 -days 3560 -in mqttServer_crt.csr -out mqttServer_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -extensions v3_req -extfile srvext.cfg -set_serial 11

openssl x509 -outform der -in mqttServer_crt.pem -out mqttServer_crt.der

xxd -i mqttServer_crt.der mqttServer_crt.der.h
```

novamente substituindo valores por C =, ST =, L =, O =, OU = e CN =, mas, desta vez, é importante que o valor CN seja o URL de sua instância da URL de mensagens IoT, que é a ID da organização seguida por ** messaging.internetofthings.ibmcloud.com **, que também deve corresponder ao campo ** subjectAltName ** no arquivo [srvext.cfg](/certificates/srvext.cfg).

Os comandos acima geram uma nova chave para o servidor, cria uma solicitação de certificado para o servidor, emite o certificado e assina-o com a chave da CA raiz, salvando-o como um arquivo pem. O certificado é convertido de pem para der formato e, por último, o comando xxd cria um arquivo de cabeçalho para incorporar o certificado no código.

### Etapa 4 - Adicionar o certificado do servidor à plataforma IoT

Agora você tem o certificado do servidor que pode carregar na plataforma IoT, na seção de configurações do console, na seção Certificados do Servidor de Mensagens, em Segurança. Selecione para ** Adicionar certificado ** e faça o upload do certificado (mqttServer_crt.pem) e da chave privada (mqttServer_key.pem). Você também precisa fornecer a senha que você forneceu ao criar a chave (senha123). Uma vez que o certificado é carregado, você o habilita definindo o Certificado Ativo Atual para a sua chave.

Você pode testar o certificado do servidor usando o openssl:

``` bash
openssl s_client -CAfile <CA certificate pem file> -showcerts -state  -servername <org ID>.messaging.internetofthings.ibmcloud.com -connect <org ID>.messaging.internetofthings.ibmcloud.com:8883
```

substitua <arquivo de certificado pem da CA> pelo nome do certificado raiz da CA e <org ID> pela ID da organização de 6 caracteres da sua instância da Plataforma IOT.

### Etapa 5 - Adicionando o certificado da CA raiz ao ESP8266

Para permitir que o ESP8266 valide o certificado do servidor, você precisa adicionar o certificado da CA raiz ao ESP8266. A biblioteca TLS que estamos usando suporta apenas o formato binário, portanto, o rootCA_certificate.der precisa ser incluído em um diretório chamado data no diretório de rascunho. Você pode descobrir onde o diretório de esboço está usando o * sketch * -> * Show sketch folder * no menu do Arduino. Dentro do diretório de esboço, crie um novo diretório chamado ** data ** e copie o arquivo rootCA_certificate.der para o diretório de dados. Você adicionou a ferramenta de upload de dados ao IDE do Arduino como parte das instruções de configuração de pré-requisito, para que agora você possa executar a ferramenta. Antes de executar a ferramenta de upload de dados, certifique-se de que a janela Serial Monitor esteja fechada, pois ela bloqueará a comunicação entre o dispositivo e a ferramenta de upload. No menu superior, selecione * Ferramentas * -> * ESP8266 Carregamento de dados de esboço *

### Etapa 6 - Adicionando o certificado da CA raiz ao seu sistema operacional ou navegador

Por fim, você precisa adicionar o certificado de CA raiz ao seu sistema operacional ou navegador, pois o console da IoT Platform usa uma conexão segura para obter os dados necessários para preencher e atualizar o console em seu navegador. Se você não adicionar o certificado raiz da CA, o console não mostrará nenhum dado.

Se estiver usando o Firefox, você precisará importar o arquivo rootCA_certificate.pem, acessando a seção de segurança das preferências. Em algumas plataformas, há uma opção Avançada antes de você poder visualizar os certificados e, em seguida, há uma opção para importar os certificados e depois confiar para identificar os sites.

Se estiver usando o Chrome, isso depende da plataforma. Em algumas plataformas, o Chrome usa os certificados do sistema, mas em outros gerencia seus próprios certificados e, assim como o Firefox, você precisa entrar nas configurações de segurança para importar o certificado de autoridade de certificação e confiar nele para identificar sites.

Para adicionar o certificado da CA raiz ao sistema operacional:

- **Linux**: Muitos navegadores no Linux não usam os certificados do sistema operacional, mas gerenciam seu próprio armazenamento de certificados, portanto, verifique antes de adicionar o certificado ao armazenamento do sistema operacional. Se você precisar adicionar o certificado rootCA ao armazenamento de certificados do CA, então, infelizmente, não há uma maneira padrão no Linux para conseguir isso. Cada distro tem uma abordagem ligeiramente diferente, mas muitos querem que o certificado seja um arquivo .crt, então use o seguinte comando para converter o arquivo .pem para .crt: `openssl x509 -outform der -in rootCA_certificate.pem -out rootCA_certificate.crt`
  - Debian: Com privilégios de administrador, copie o arquivo rootCA_certificate.crt para / usr / share / ca-certificates e, em seguida, execute`dpkg-reconfigure ca-certificates`
  - Fedora: Copie o arquivo rootCA_certificate.pem para **/etc/pki/ca-trust/source/anchors/** (usando sudo mv ou outro acesso root) e execute o comando `update-ca-trust extract` com privilégios de administrador.
  - Ubuntu: Copie o rootCA_certificate.crt para ** / usr / local / share / ca-certificates ** usando privilégios de administrador e execute `update-ca-certificates`.
- **MacOS**: DBasta clicar no certificado no Finder para abri-lo no aplicativo Acesso às Chaves. Ele será mostrado automaticamente como não confiável. Clique duas vezes para abrir a janela de detalhes do certificado e, em seguida, expanda a seção **Trust**. Altere o valor do SSL para **Sempre Confiável**. Feche a janela do certificado (será solicitada a senha da sua conta para verificar a alteração).
- **Windows**: Inicie o Microsoft Management Console (digite mmc no menu Iniciar) e selecione *Arquivo* -> *Adicionar / Remover Snap-in ...*. Destaque Certificados e pressione **Adicionar**. Selecione para gerenciar certificados para **Conta de computador**, **Computador local** e pressione **Concluir** e depois **OK**. De volta ao mmc, selecione o item Certificados na coluna da esquerda, clique com o botão direito do mouse no item **Autoridades de certificado raiz confiáveis**. No menu pop-up, selecione *Todas as Tarefas* -> *Importar ...* para iniciar o Assistente de Importação de Certificados. Selecione o arquivo pem ou root do certificado rootCA_ (talvez seja necessário alterar o filtro para mostrar todos os arquivos) e coloque-o na loja **Autoridades de certificado raiz confiáveis**.

**Note** : *Se você estiver adicionando um certificado a um gerenciador de certificados do navegador, certifique-se de adicionar um certificado da Autoridade de Certificação. Isso deve permitir que você importe um arquivo .pem ou .der. Se estiver solicitando um arquivo .p12, você está tentando importar um certificado e uma chave, portanto, estão na seção errada do gerenciador de certificados. Você deseja adicionar um certificado **Certificate Authority** ou uma cadeia de certificados.*

### Etapa 7 - Atualizando o Código ESP8266 para Usar o Certificado para Estabelecer uma Conexão Segura

Quando um servidor se conecta usando SSL / TLS, ele apresenta seu próprio certificado para verificação. O cliente usa seu repositório de certificados de autoridade de certificação local para validar se o certificado apresentado pelo servidor é autêntico, validando se uma autoridade de certificação conhecida assinou o certificado.

Parte do processo de verificação de certificado verifica se o certificado está em dados (não antes do horário de início do certificado e não após o tempo de expiração do certificado), portanto, o ESP8266 precisa saber a data / hora corretas. O Network Time Protocol pode ser usado para obter o horário correto dos servidores da Internet.

Você já fez o upload do certificado de CA para o ESP8266, portanto, agora o código precisa ser atualizado para carregar o certificado do sistema de arquivos flash e alternar para o uso de uma conexão SSL / TLS.

Faça as seguintes alterações no código:

- Adicione uma inclusão na parte superior do arquivo para acessar o sistema de arquivos: `#include <FS.h>`
- Adicione uma linha após o **ESP8266WiFi.h**, para adicionar tempo : `#include <time.h>`
- Altere o MQTT_PORT para usar a porta segura 8883: `#define MQTT_PORT 8883`
- Adicione um novo #define para nomear o certificado de CA : `#define CA_CERT_FILE "/rootCA_certificate.der"`
- Mude o wifiClient para usar a versão segura : `WiFiClientSecure wifiClient;`
- Adicione #define para definir o timezone : `#define TZ_OFFSET -5  //Hours timezone offset to GMT (without daylight saving time)`
- Adicione #define para definir horário de verão : `#define TZ_DST    60  //Minutes timezone offset for Daylight saving`

- Modifique o código de conexão do MQTT na função setup()  para estabelecer uma conexão segura:

```C++
  // Get certs from file system and load into WiFiSecure client
  SPIFFS.begin();
  File ca = SPIFFS.open(CA_CERT_FILE, "r");
  if(!ca) {
    Serial.println("Couldn't load cert");
  } else {
    bool ret = wifiClient.loadCACert(ca);
    Serial.print("Loading CA cert returned ");
    Serial.println((ret)? "true" : "false");
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

  // Connect to MQTT - IBM Watson IoT Platform
  while(! mqtt.connected()){
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
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
```

Salve, compile e faça o upload do código e agora você deve ter uma conexão segura. Se você observar o console da IoT Platform, na seção de dispositivos, você deverá ver o estado da conexão, na seção Identidade ao selecionar o dispositivo, conectado com  **SecureToken**.  Anterior o status teria mostrado **Insecure**.

Agora você deve entrar na seção de configurações da IoT Platform e atualizar a política de segurança de conexão de **TLS Opcional** para **TLS com Autenticação Token** e depois **Salve** a mudança.

### Etapa 8 - Como funciona o sistema de arquivos SPIFFS

O ESP8266 permite que parte da memória flash interna ou conectada seja usada como um sistema de arquivos. O plugin do Arduino IDE permite que você personalize o tamanho do sistema de arquivos (* Ferramentas * -> * Tamanho do Flash * permite que você especifique 1MB ou 3MB para o sistema de arquivos quando uma placa NodeMCU é o dispositivo de destino). O sistema de arquivos SPIFFS é um sistema de arquivos muito simples, que não suporta diretórios. É uma lista simples de arquivos, no entanto, os nomes de arquivos podem incluir o caractere '/' para dar uma noção da estrutura do diretório. Nomes de arquivos não devem ter mais de 31 caracteres.

A ferramenta de upload de dados permite que o diretório de dados de conteúdo na pasta de esboço seja convertido em um sistema de arquivos SPIFFS e carregado no dispositivo, onde o conteúdo pode ser acessado a partir do aplicativo.

O sistema de arquivos SPIFFS está incluído em um esboço incluindo o cabeçalho apropriado: `#include <FS.h>`, então é inicializado com uma chamada a função **SPIFFS.begin()**.

O código do aplicativo abre os arquivos de certificado usando a função **open()**  e especificando para permitir somente operações de leitura.  O **WiFiClientSecure** pode carregar os certificados das alças abertas do arquivo usando as funções **load()**.

Quando você terminar com um arquivo, ele pode ser fechado com a função **close()**.

Mais detalhes e a API completa podem ser vistos no [documentação](https://arduino-esp8266.readthedocs.io/en/2.4.1/filesystem.html)

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
    if (mqtt.connect(MQTT_DEVICEID, MQTT_USER, MQTT_TOKEN)) {
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