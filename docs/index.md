# Real World IoT with the ESP8266

## Welcome to the ESP8266 IoT Workshop

IoT workshop based on ESP8266, a DHT11/22 and NeoPixel RGB LED with data analysis on the IBM Cloud.

### Stream Environmental Conditions to The Cloud

Learn how to connect an ESP8266 to the **IBM Internet of Things (IoT) Platform** over MQTT and stream environmental data from the sensors to the IBM Cloud.  

Workshop attendees will learn about ESP8266 programming, IoT Security, MQTT, IoT Platform, Node-RED, cloud storage, data analytics and visualisation techniques.

## Navigation

To move through the workshop you can use the top menu to select a specific section or use the **Next ->** button in the top menu to move to then next section as you finish each section.

## Access to workshop material

The source for this workshop is hosted on [GitHub](https://github.com/binnes/esp8266Workshop) and this site is automatically generated from the Markdown in the GitHub repository.

There is also a downloadable PDF containing the workshop instructions available [here]{https://binnes.github.io/esp8266Workshop/pdf/}

## Typical agenda for a workshop day

This workshop works well as a face-to-face workshop taking the majority of a day.  A typical agenda can be seen [here](AGENDA.md).

To help the flow of a face to face event having the [prerequisite](part1/PREREQ.md) software installed can be helpful.

## Course outline

### [Part 1](part1/README.md)

Provides an overview to the course, introduces the hardware, the development tooling and then gets you programming the ESP8266 device to connect to the local WiFi network and be able to control the hardware.
Part 1 finishes with an overview of the IBM Cloud, the cloud platform used in this workshop and ensures you have a working cloud account with the required resources.

### [Part 2](part2/README.md)

The second part of the workshop looks at the Internet of Things service on the IBM Cloud and how you connect a device to the IBM Cloud using the MQTT protocol.  This section also looks at ensuring you have a secure connection between the device and the Cloud Platform, using SSL/TLS security and certificates.

### [Part 3](part3/README.md)

In this section we look at using a low-code development environment called Node-RED on the IBM Cloud to implement the server side part of the IoT solution.  You will create a dashboard to visualise the IoT data and also provide controls to configure the ESP8266 device.  Your server side application will also control the LED attached to the ESP8266.

### [Part 4](part4/README.md)

The last part of the workshop looks at how useful information can be extracted from the IoT data using analytics.  You will be introduced to the Analytic services available on the IBM Cloud and the tooling the services provide to help you extract useful information from sensor data.

Timing of the day can be found in the [**agenda**](AGENDA.md)

We've provided all the links used throughout the workshop as well as links to other resources [**here**](RESOURCES.md) to help you explore a little more about IoT.
