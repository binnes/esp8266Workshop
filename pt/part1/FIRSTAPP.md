*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
***
**Parte 1** - [Configuração](PREREQ.md) - [Primeira App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [**DHT**](DHT.md) - [Cloud](IOTCLOUD.md)
***


# Seu primeiro aplicativo ESP8266

## Objetivos

Este laboratório mostrará a você como usar o Arduino IDE com o plugin ESP8266 para criar um novo aplicativo para a placa ESP8266. Você aprenderá como:

- Verifique se você tem as configurações corretas no IDE
- Como compilar o código fonte em um binário
- Como carregar um binário na placa
- Você também deve ter tempo para entender o fluxo de um aplicativo Arduino, e a finalidade das funções **setup()** e **loop()**.

### Etapa 1 - Configurando o ambiente do Arduino para o ESP8266

Vamos começar com um aplicativo simples para exibir informações sobre a memória flash. Comece configurando seu Arduino IDE para as configurações corretas para a placa. Usando o menu * Ferramentas *, verifique se as seguintes configurações estão definidas:

- Placa : **NodeMCU 1.0 (ESP-12E Module)**
- Flash : **4M (1M SPIFFS)**
- Porta Debug : **Disabled**
- Nível Debug : **None**
- IwIP Variant : **v2 Lower Memory**
- Frequência CPU: **160 MHz**
- Velocidade de Upload : **115200**
- Erase Flash : **Only Sketch**
- Port : *Conecte o ESP8266 ao seu laptop usando um cabo MicroUSB e selecione sua porta, dependendo do sistema operacional*

### Etapa 2 - Carregando um esboço de exemplo

Em seguida, escolha * Arquivo * -> * Exemplos * -> * ESP8266 * -> * CheckFlashConfig * no menu para abrir uma nova janela com o esboço de amostra pré-carregado (você pode fechar a janela anterior, pois ela não é necessária).

### Etapa 3 - Compilando o rascunho

![Comando de Verificação](../images/verify.png)

Agora você pode compilar o esboço para o ESP8266 selecionando o **Verificar** botão na barra de comando (ícone de carrapato) ou usando a opção de menu * sketch * -> * Verificar / Compilar *. Você verá que existem atalhos de teclado para vários comandos, mostrados ao lado da opção de menu que você pode querer aprender e usar.

### Etapa 4 - Fazendo o upload do esboço

![Comando de Upload](../images/upload.png)

Quando a compilação terminar, você pode carregar o novo aplicativo no ESP8266 usando o botão ** upload ** na barra de comando (seta para o ícone à direita) ou usando a opção de menu * Sketch * -> * Upload *.

*Nota*: * você não precisa compilar e fazer o upload. Basta usar o upload para compilar o aplicativo, se necessário, e enviá-lo para o ESP8266 *

Se você tentar salvar o esboço, será solicitado a inserir um nome / local para o esboço. Isso ocorre porque os esboços de exemplo são somente leitura, se você quiser modificá-los e salvar a modificação necessária para salvá-la em um novo local.

Este exemplo de esboço imprime informações sobre a memória flash a bordo do ESP8266. Para ver a saída, você precisa abrir o Monitor Serial.

![Monitor Serial](../images/SerialMonitor.png)

Certifique-se de que a taxa de transmissão na parte inferior da janela do monitor corresponda à taxa de transmissão na função de configuração do esboço `Serial.begin(115200);`.

### Etapa 5 - Entenda o esboço do exemplo

O Arduino IDE e o tempo de execução cuidam do trabalho necessário para configurar o tempo de execução de um aplicativo e fornecem dois pontos de entrada.  A função **setup()** , que é chamada no início do aplicativo, ou quando o dispositivo sai de um sono profundo.  O outro ponto de entrada é a função **loop()** que é chamada repetidamente desde que o dispositivo esteja em execução.

Não há nenhum sistema operacional rodando sob o aplicativo Arduino, o código que você insere na configuração e o loop é tudo o que está rodando na CPU ESP8266.

Este exemplo de esboço inicializa a conexão Serial na função **setup()** em seguida, recupera e imprime informações sobre a memória flash para o console Serial na função **loop()**.  Ao final da função **loop()** function há uma pausa de 5 segundos (5000 milissegundos).  Depois da pausa a função **loop()** finaliza, mas é chamada novamente.

***
*Links Rápidos :*
**Parte 1** - [Configuração](PREREQ.md) - [Primeira App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [**DHT**](DHT.md) - [Cloud](IOTCLOUD.md)
***
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
