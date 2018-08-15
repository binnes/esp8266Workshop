*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***

# Registrando um novo dispositivo no Watson IoT Platform

## Objetivos

Este laboratório mostrará como registrar seu ESP8266 com a plataforma IBM Watson Internet of Things. No laboratório você aprenderá:

- Como navegar para o console da IoT Platform
- Como definir um tipo de dispositivo e registrar um dispositivo na plataforma IoT

### Introdução

Antes de poder conectar um dispositivo ao Watson IoT Platform, você precisa definir como o dispositivo se conectará à plataforma e também registrar o dispositivo para gerar um token de acesso para o dispositivo. Isso será usado para verificar a identidade do dispositivo (voltaremos à autenticação do dispositivo posteriormente nesta parte do workshop).

Você precisa decidir como deseja agrupar dispositivos, por função, por tipo de hardware, etc. Cada dispositivo registrado na plataforma deve ser registrado em um tipo de dispositivo. Não há restrições sobre como os dispositivos são agrupados e os tipos de dispositivos. Para esta oficina, criaremos um tipo de dispositivo representando os dispositivos ESP8266.

### Etapa 1 - Iniciar o console do Watson IoT Platform

No IBM Cloud, navegue até seu painel usando o menu superior * - * -> * Dashboard * e, em seguida, selecione seu aplicativo clichê. Na seção de visão geral do aplicativo, selecione o serviço iotf em Conexões. Isso levará você ao serviço da Plataforma IoT. Inicie o console.

### Etapa 2 - Adicionar um novo tipo de dispositivo para dispositivos ESP8266

Etapa 2 - Adicionar um novo tipo de dispositivo para dispositivos ESP8266 Navegue até a seção Devices do console e selecione a seção ** Device Types **. Pressione o botão ** + Adicionar tipo de dispositivo ** e insira o seguinte:

- Tipo : Certifique-se de que o dispositivo esteja selecionado (NÃO gateway)
- Nome : Escreva **ESP8266**
- Descrição : Escreva **Esp8266 environment monitor**

Selecione **Próximo** depois **Finalizar**

### Etapa 3 - Registre sua placa ESP8266 na plataforma IoT

Agora você tem a oportunidade de registrar um dispositivo. Continue com o fluxo simples por enquanto e pressione **Register Device**. O tipo de dispositivo ESP8266 deve ser pré-selecionado. Agora você precisa inserir um ID de dispositivo exclusivo. Novamente, você pode escolher como deseja identificar dispositivos. Para o workshop, use um formato simples, como **dev01**.

Pressione o botão **Próximo** duas vezes e você será solicitado a fornecer um token. Ao desenvolver, recomendo escolher um token que você possa lembrar facilmente. Eu configurei todos os meus dispositivos para usar o mesmo token ao desenvolver, mas obviamente isso não é uma boa prática de produção.

Cada vez que você conectar o dispositivo, o token precisará ser apresentado ao servidor e, assim que o dispositivo for registrado, não há como recuperar um token. Você precisará excluir e registrar novamente o dispositivo se o token for perdido.

Digite um token para o seu dispositivo e pressione **Próximo**. Você verá um resumo do dispositivo. Pressione **Concluído** para concluir o registro do dispositivo. Agora você verá uma página de detalhamento do dispositivo - essa é a última chance de ver o token. Depois de sair desta página, o token não pode ser recuperado. Anote a Org, o Tipo de Dispositivo, o ID do Dispositivo e o Token de Autenticação. Você pode até considerar fazer uma captura de tela.

***
**Parte 2** - [Registro de Dispositivo](DEVICE.md) - [**Aplicação**](APP.md) - [MQTT](MQTT.md) - [Certificado Servidor](CERT1.md) - [Certificado Cliente](CERT2.md)
***
*Links Rápidos :*
[Início](/README.pt.md) - [Parte 1](part1/README.md) - [Parte 2](part2/README.md) - [Parte 3](part3/README.md) - [Parte 4](part4/README.md)
