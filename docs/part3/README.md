# Part 3

## Introduction to Node-RED

- Estimated duration: 10 min
- practical [**Node-RED Setup**](NODERED.md)

## Receive Environmental Sensor Data in Node-RED

In this lab you will set up Node-RED in your Watson IoT Starter application created at the end of Part 1 and learn about low code programming with Node-RED.

- Estimated duration: 10 min
- practical [**Environmental Sensor Data**](DHTDATA.md)

## Node-RED Dashboard - Real Time Chart

In this lab you will import Node-RED flows which create Dashboard Charts. After learning about Node-RED Dashboard Charts, you will be able to display temperature and humidity graphs of the Device environmental sensors.

- Estimated duration: 15 min
- practical [**Plot Environment Sensor Data**](DASHBOARD.md)

## Store data in Cloudant storage

In this lab you will store the device environmental sensor data in a Cloudant database in IBM Cloud.

- Estimated duration: 10 min
- practical [**Write Sensor Data to Cloud Storage**](CLOUDANT.md)

## Node-RED Dashboard - Historical Playback Chart

In this lab you will read the historical sensor data from a Cloud storage database and create a graph of prior readings

- Estimated duration: 10 min
- practical [**Read Cloud Storage and Plot History Chart**](HISTORY.md)

## Control your Device reporting interval

In this lab you will modify the ESP8266 Arduino program to receive MQTT commands from the IBM Cloud and build a Node-RED Dashboard Form to dynamically change the reporting interval of the ESP8266 DHT environmental sensor data.

- Estimated duration: 20 min
- practical [**Change the Sensor Reporting Interval Dynamically**](INTERVAL.md)

## Control your LED via Device Commands

In this lab you will modify / control your Device program to receive MQTT commands from the IBM Cloud and build a Node-RED flow to dynamically change the LED color of the device depending on Alert thresholds.

- Estimated duration: 20 min
- practical [**Control the LED Alert colors from the Cloud**](LED.md)
