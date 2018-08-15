*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
***
**Parte 1** - [Configuração](PREREQ.md) - [Primeira App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [**DHT**](DHT.md) - [Cloud](IOTCLOUD.md)
***

# Conectando o ESP8266 a uma rede WiFi

## Objetivos

Este laboratório mostrará como conectar seu ESP8266 a uma rede WiFi local. Este laboratório também apresentará o Serial Monitor, que permite ver a saída de um aplicativo em execução. No final deste laboratório você deve:

- Ser capaz de adicionar uma conexão Wi-Fi a um esboço
- Ser capaz de adicionar uma conexão Serial e gerar saída para a conexão serial.
- Entenda as chamadas de função necessárias para iniciar as conexões WiFi e Serial, em seguida, como usar as conexões e onde encontrar a documentação sobre as funções disponíveis.

### Introdução

Na prática do Blinky, você verificou que tinha um ambiente de desenvolvimento em funcionamento e fez o upload de seu primeiro aplicativo para o ESP8266. Agora vamos começar a explorar algumas das funcionalidades mais avançadas do ESP8266, começando com a interface WiFi integrada.

O ESP8266 possui uma interface WiFi integrada que suporta rede 802.11 b / g / n 2.4 GHz. Freqüências de 5GHz não são suportadas. O ESP8266 pode ser configurado para ser um ponto de acesso ou para se unir a uma LAN sem fio existente. Vamos nos juntar a uma LAN na oficina.

### Etapa 1 - Carregar um esboço de exemplo

No IDE do Arduino, carregue o esboço de exemplo do WiFiScan, usando * File * -> * Examples * -> * ESP8266WiFi * -> * WiFiScan * e carregue o sketch no seu ESP8266. Este esboço irá procurar por redes WiFi locais e exibir os resultados.

### Etapa 2 - Execute o esboço e a saída do monitor

![Monitor Serial](../images/SerialMonitor.png)

Para exibir os resultados, o esboço está usando a interface Serial no ESP8266 para enviar a saída para. Esta saída será enviada de volta para a porta USB do seu laptop / estação de trabalho. Para ver a saída, você precisa abrir o Serial Monitor, que é o ícone da lupa no canto superior direito do IDE. Você deve garantir que a taxa de transmissão definida no monitor serial corresponda à velocidade do `Serial.begin(115200);` instrução na função de configuração no esboço.

A cada 5 segundos, você verá a placa procurando redes disponíveis e, em seguida, emitirá o que encontrar na porta serial.

### Etapa 3 - Acesse a documentação da biblioteca ESP8266 aprimorada

Você pode obter documentação sobre como usar o ESP8266 no Arduino e as bibliotecas que estão instaladas com o plugin ESP8266  [aqui](http://arduino-esp8266.readthedocs.io/en/latest/index.html).  Se você concluir esta atribuição, modifique o esboço para mostrar o número do canal que cada rede está usando e o tipo de criptografia, além do SSID e do RSSI (intensidade do sinal).

### Etapa 4 - Como se conectar a uma rede WiFi

O exemplo de esboço ** WiFiClient ** mostra como se conectar a uma rede WiFi, fornecendo um SSID e senha, que usaremos na parte 2 do workshop. Carregue o sketch (* File * -> * Examples * -> * ESP8266WiFi * -> * WiFiClient *) e examine o código, anote como as credenciais da rede WiFi são inseridas para entrar em uma rede.

*Observação: você não precisa executar este exemplo e solicitar as credenciais sparkfun, basta percorrer o código e ver como a conexão com o WiFi é criada. *

### Etapa 5 - Entendendo o padrão de uso da Biblioteca ESP8266

Agora você viu dois esboços de exemplo diferentes usando as conexões Serial e WiFi. Você pode começar a ver um padrão sobre como usar os recursos:

- Como opção, inclua o cabeçalho obrigatório, como `#include "ESP8266WiFi.h"`
- Na função **setup()**  inicializar a biblioteca, geralmente com uma chamada begin () e / ou parâmetros de configuração
- Na função **loop()** acessar recursos da biblioteca

* Nota *: * Se você terminar o salto de volta ao passo 3 para adicionar a funcionalidade adicional

***
*Links Rápidos :*
**Parte 1** - [Configuração](PREREQ.md) - [Primeira App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [**DHT**](DHT.md) - [Cloud](IOTCLOUD.md)
***
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
