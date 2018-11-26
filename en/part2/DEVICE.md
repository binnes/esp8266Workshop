*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
***
**Part 2** - [**Device Registration**](DEVICE.md) - [Application](APP.md) - [MQTT](MQTT.md) - [Server Certificate](CERT1.md) - [Client Certificate](CERT2.md)
***

# Registering a new device to the Watson IoT Platform

## Lab Objectives

This Lab will show you how to register your ESP8266 with the IBM Watson Internet of Things Platform.  In the lab you will learn:

- How to navigate to the IoT Platform console
- How to define a device type and register a device in the IoT Platform

### Introduction

Before you can connect a device to the Watson IoT Platform you need to define how the device will connect to the platform and also register the device to generate an access token for the device.  This will be used to verify the device identity (we will come back to device authentication later in this part of the workshop).

You need to decide how you want to group devices, by function, by hardware type, etc.  Each device registered on the platform must be registered against a device type.  There are no restrictions about how devices are grouped and the device types, for this workshop we will create a device type representing the ESP8266 devices.

### Step 1 - Launch the Watson IoT Platform console

In the IBM Cloud navigate to your dashboard using the top menu *≡* -> *Dashboard*, then select your starter kit application.  In the overview section of the application select the iotf-service under Connections.  This will take you to the IoT Platform service.  Launch the console.

### Step 2 - Add a new device type for ESP8266 devices

Navigate into the Devices section of the console and ensure you are in the **Browse** section.  Press the **+ Add Device** button the enter the following:

- Device Type : Enter **ESP8266**
- Device ID : Enter **dev01**

Select **Next** then **Next** to skip over the device information input screen

### Step 3 - Specify a token for the device

You are now being prompted to provide a token.  When developing I recommend choosing a token you can easily remember.  I set all my devices to use the same token when developing, but obviously this is not a good production practice.

Each time you connect the device the token will need to be presented to the server and once the device is registered there is no way to recover a token, you will need to delete and reregister the device if the token is lost.

Enter a token for your device then press **Next**.  You will see a summary of the device.  Press **Done** to complete the device registration.  You are now shown a device Drilldown page - this is the last chance you get to see the token.  Once you leave this page the token can not be recovered. Write down the Org, Device Type, Device ID and Authentication Token. You might even consider taking a screen shot.

***
**Part 2** - [**Device Registration**](DEVICE.md) - [Application](APP.md) - [MQTT](MQTT.md) - [Server Certificate](CERT1.md) - [Client Certificate](CERT2.md)
***
*Quick links :*
[Home](/README.md) - [Part 1](../part1/README.md) - [**Part 2**](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
