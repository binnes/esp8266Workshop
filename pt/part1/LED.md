*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](../part1/README.md) - [Parte 2](../part2/README.md) - [Parte 3](../part3/README.md) - [Parte 4](../part4/README.md)
***
**Parte 1** - [Configuração](PREREQ.md) - [Primeira App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [**DHT**](DHT.md) - [Cloud](IOTCLOUD.md)
***

# Controlando o LED RGB do ESP8266

## Objetivos

Neste laboratório, você conectará o LED NeoPixel e aprenderá como controlá-lo a partir do ESP8266. Você vai aprender:

- As conexões elétricas do LED e como se conectar ao ESP8266
- A biblioteca usada para controlar o neopixel
- Como adicionar novas bibliotecas ao Arduino IDE
- Como usar a biblioteca neopixel e acessar a documentação para recursos adicionais

### Introdução

Durante a última prática usamos a biblioteca ESPWiFi que foi instalada como parte do plugin, mas agora queremos controlar um neopixel RGB LED que conectaremos ao ESP8266. Uma das vantagens de usar o Arduino é que existem muitas bibliotecas disponíveis, portanto, a maioria dos hardwares comuns normalmente terá uma biblioteca do Arduino disponível, portanto, você não precisará implementar o protocolo de controle de baixo nível para um dispositivo.

Você precisa ter cuidado para garantir que qualquer biblioteca escolhida ofereça suporte ao hardware em que você está executando. Inicialmente, a plataforma Arduino foi criada em torno dos microprocessadores AVR e muitas bibliotecas foram escritas para interagir diretamente com os processadores AVR, portanto, são incompatíveis quando se trata de um processador diferente. Olhando para a documentação do Arduino ESP8266 há uma [lista de bibliotecas](http://arduino-esp8266.readthedocs.io/en/latest/libraries.html#other-libraries-not-included-with-the-ide) conhecidas por trabalharem com ESP8266.

### Etapa 1 - Adicionando uma biblioteca ao Arduino IDE

Olhando para a lista, há uma biblioteca NeoPixel compatível disponível para o neopixel. Para instalar uma biblioteca no Arduino IDE, você pode usar o Gerenciador de bibliotecas. No menu, selecione * Sketch * -> * Include Library * -> * Manage Libraries ... * para abrir o Library Manager. Na caixa de pesquisa, insira NeoPixel para encontrar bibliotecas que correspondam à pesquisa. Você pode ver que há um número de bibliotecas disponíveis, mas você quer encontrar o Adafruit NeoPixel da Adafruit, em seguida, selecione a entrada e clique em instalar para instalar a biblioteca. Uma vez que a biblioteca instalada, clique em ** fechar ** para fechar o Gerenciador de biblioteca.

### Passo 2 - Conectando o Neopixel à placa ESP8266

Agora você precisa conectar o NeoPixel ao ESP8266. Antes de começar a fazer qualquer conexão, desconecte o dispositivo do seu laptop / estação de trabalho para que não haja energia no dispositivo. Você nunca deve fazer alterações de conexão quando o dispositivo estiver ligado.

Antes de fazer as conexões, precisamos identificar os 4 pinos de conexão que saem do LED. Se você examinar o aro da tampa do pixel, verá que um dos lados está achatado (este deve ser o lado oposto do pino mais curto) - este pino próximo ao lado achatado é o pino ** Data Out **. Nós não estaremos usando este pino, pois temos apenas um único pixel. Você pode encadear pixels juntos, conectando o pino ** Data Out ** ao pino ** Data In ** do próximo pixel da cadeia.

O pino mais curto no Pixel é o **Data In**
O pino mais longo do Pixel é **Ground**
O pino restante é **v' tensão**, que deve ser 5v, mas funciona com 3.3v que a placa ESP8266 fornece.

Assim, com o pino mais curto à esquerda e o lado plano à direita, a pinagem é (da esquerda para a direita):

- Data In (pino mais curto)
- +'ve Tensão
- Gnd (pino mais longo)
- Data Out (sem conexão)

É necessário conectar a entrada de dados, a tensão + e a terra à placa ESP8266, conforme mostrado no diagrama. Tome cuidado para garantir que as conexões estejam como mostradas, já que conectar os pinos errados pode danificar a placa ESP8266 e / ou o LED:

![Cabeamento NodeMCU LED](../images/NodeMCU_LED_Wiring.jpg)

### Etapa 3 - Carregar um esboço de exemplo

Depois de ter feito as conexões, você pode conectar a placa ao seu laptop. Carregue o sketch do exemplo ** strandtest ** *File* -> *Examples* -> *AdaFruit Neopixel* -> *strandtest*. Você precisa fazer algumas alterações no esboço de exemplo:

1. Altere o número PIN para 5. D1 na placa NodeMCU para GPIO5 no processador ESP8266 - consulte o[pinout](https://circuits4you.com/2017/12/31/nodemcu-pinout/)
2. Defina o número de pixels para 1 na linha de definição da faixa
3. Na função loop, comente as 4 linhas que começam com **theatreChase** como estes causam flashes rápidos quando apenas um único LED está conectado, o que não é agradável de se olhar.

Ao salvar o arquivo, você deverá ser solicitado a salvá-lo como um novo arquivo (não é possível substituir os arquivos de exemplo, portanto, é necessário salvá-los em outro local para poder modificá-los).

Compile e carregue o esboço para ver o LED mudar cores.

O pedaço do seu código deve ser assim:

```cpp
#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

#define PIN 5

// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//   NEO_RGBW    Pixels are wired for RGBW bitstream (NeoPixel RGBW products)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(1, PIN, NEO_GRB + NEO_KHZ800);

// IMPORTANT: To reduce NeoPixel burnout risk, add 1000 uF capacitor across
// pixel power leads, add 300 - 500 Ohm resistor on first pixel's data input
// and minimize distance between Arduino and first pixel.  Avoid connecting
// on a live circuit...if you must, connect GND first.

void setup() {
  // This is for Trinket 5V 16MHz, you can remove these three lines if you are not using a Trinket
  #if defined (__AVR_ATtiny85__)
    if (F_CPU == 16000000) clock_prescale_set(clock_div_1);
  #endif
  // End of trinket special code


  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

void loop() {
  // Some example procedures showing how to display to the pixels:
  colorWipe(strip.Color(255, 0, 0), 50); // Red
  colorWipe(strip.Color(0, 255, 0), 50); // Green
  colorWipe(strip.Color(0, 0, 255), 50); // Blue
//colorWipe(strip.Color(0, 0, 0, 255), 50); // White RGBW
  // Send a theater pixel chase in...
  //theaterChase(strip.Color(127, 127, 127), 50); // White
  //theaterChase(strip.Color(127, 0, 0), 50); // Red
  //theaterChase(strip.Color(0, 0, 127), 50); // Blue

  rainbow(20);
  rainbowCycle(20);
  //theaterChaseRainbow(50);
}
```

### Passo 4 - Entendendo como usar a biblioteca neopixel

Para adicionar o NeoPixel à sua própria aplicação, você precisa fazer o seguinte:

1. Crie uma instância de um Neopixel `Adafruit_NeoPixel strip = Adafruit_NeoPixel(1, PIN, NEO_GRB + NEO_KHZ800);`
    - The first parameter is the number of pixels in the chain
    - o segundo pixel é o número do GPIO ao qual o pixel está conectado
    - O terceiro parâmetro permite identificar o tipo de pixel conectado. Existem vários tipos diferentes de pixels. Alguns incluem um LED branco para dar uma melhor luz branca. Alguns esperam que os dados verdes sejam enviados primeiro, enquanto outros exigem que os dados vermelhos sejam enviados primeiro. Existem também diferentes velocidades de comunicação usadas.
2. Antes de usar e comandos para alterar os pixels, você precisa inicializar a biblioteca de pixels usando a função **begin()** .  `strip.begin();`  Isso geralmente é feito na função **setup()** .
3. Defina os pixels para as cores desejadas (nota: isso não altera as cores dos pixels imediatamente)
    - Há um número de chamadas na biblioteca neopixel para poder definir a cor de um pixel. O primeiro parâmetro é sempre o número do pixel que você deseja definir na cadeia (começando com 0 como o primeiro pixel):
        - `setPixelColor(uint16_t n, uint8_t r, uint8_t g, uint8_t b)`
        - `setPixelColor(uint16_t n, uint8_t r, uint8_t g, uint8_t b, uint8_t w)`
        - `setPixelColor(uint16_t n, uint32_t c)`
    - Existem duas maneiras de especificar uma cor para o **setPixelColor()** .  Você pode passar os valores vermelho, verde, azul e opcionalmente branco (0 - 255) para cada um dos LEDs dentro do pixel ou usar a função **Color()** para criar um valor inteiro de 32 bits representando uma cor.  Isso pode ser útil para passar e retornar de outras chamadas de função, conforme mostrado no exemplo de esboço:
        - `Color(uint8_t r, uint8_t g, uint8_t b)`
        - `Color(uint8_t r, uint8_t g, uint8_t b, uint8_t w)`
4. Chame a função **show()**  para enviar as alterações de cor para o (s) pixel (s): `strip.show();`.  Essa é a função que atualiza os pixels com base nas chamadas de função setPixelColor anteriores.

Para qualquer biblioteca instalada com o Arduino Library Manager, você pode acessar a documentação da biblioteca usando o **More info** link no gerenciador de bibliotecas:

![NodeMCU LED Cabeamento](../images/LibraryManagerInfo.png)

***
*Links Rápidos :*
**Parte 1** - [Configuração](PREREQ.md) - [Primeira App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [**DHT**](DHT.md) - [Cloud](IOTCLOUD.md)
***
[Início](/README.pt.md) - [Parte 1](../part1/README.md) - [Parte 2](../part2/README.md) - [Parte 3](../part3/README.md) - [Parte 4](../part4/README.md)

