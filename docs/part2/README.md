# Part 2

## Introduction to the IBM Internet of Things Platform

The IBM Internet of Things Platform is a set of services provided on the IBM Cloud to enable you to collect IoT data using MQTT events, we will cover MQTT later in this section.  In addition to data ingest, the IoT platfom provides a number of other services to allow you to capture the IoT data into short term storage in a NoSQL database, monitor and analyze the IoT data and archive the data in Cloud Object Storage.

Before connecting the ESP8266 device to the IoT Platform you will configure the platform to allow the device to connect then later in this section you will configure connection security to secure communications between the ESP8266 device and IBM Cloud.

## Device Type / Device Creation

This Lab will show you how to register your ESP8266 with the IBM Internet of Things Platform.

- Estimated duration: 15 min
- practical [**Create device type and device**](DEVICE.md)

## Creating the initial application

In this lab you will pull together all the information from part 1 into a single app.

- Estimated duration: 15 min
- practical [**Create ESP8266 application**](APP.md)

## Introduction to the MQTT protocol

In this lab you will learn how to add MQTT messaging to an application.

- Estimated duration: 15 min
- practical [**Sending data to the Watson IoT platform using MQTT**](MQTT.md)

## Introduction to IoT Security techniques

In this Lab you will modify MQTT to use a secure connection.

- Estimated duration: 25 min
- practical [**Securing the MQTT traffic using self-signed certificate**](CERT1.md)

## Adding client certificates

In this lab you will extend the application by enabling client side certificates.

- Estimated duration: 10 min
- practical [**Securing the MQTT traffic using a client certificate**](CERT2.md)
