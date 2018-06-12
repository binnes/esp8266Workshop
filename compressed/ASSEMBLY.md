*Quick links :*
[Home](/README.md) - [Compressed Part 1](/compressed/PART1.md) - [Compressed Part 2](/compressed/PART2.md) - [Compressed Part 3](/compressed/PART3.md) - [Compressed Part 4](/compressed/PART4.md)
***

# Assembling the RGB LED and DHT-11 with the ESP8266

## Lab Objectives

In this Lab you will connect the NeoPixel LED and DHT11 Temperature sensor and learn how to control it from the ESP8266.  You will learn:

- The electrical connections of the LED and how to connect to the ESP8266
- The electrical connections needed to connect the DHT sensor to the ESP8266

### Introduction

### Step 1 - Connecting the Neopixel to the ESP8266 board

Now you need to connect the NeoPixel to the ESP8266.  Before you start making any connections please disconnect the device from your laptop/workstation so there is no power getting to the device.  You should never make any connection changes when the device is powered on.

Before making the connections we need to identify the 4 connecting pins coming out of the LED.  If you examine the rim of the pixel cover you will see that one side is flattened (this should be the opposite side from the shortest pin) - this pin next to the flattened side is the **Data Out** pin.  We will not be using this pin, as we only have a single pixel.  You can chain pixels together connecting the **Data Out** pin to the **Data In** pin of the next pixel in the chain.

The shortest pin on the Pixel is the **Data In**
The longest pin on the Pixel is **Ground**
The remaining pin is **+'ve voltage**, which should be 5v, but it works with 3.3v that the ESP8266 board provides.

So, with the shortest pin on the left and the flat side on the right the pinout is (left to right):

- Data In (shortest pin)
- +'ve Voltage
- Gnd (longest pin)
- Data Out (no connection)

You need to connect the Data In, +'ve voltage and ground to the ESP8266 board as shown in the diagram.  Take care to ensure that the connections are as shown, as connecting the wrong pins can damage the ESP8266 board and/or the LED:

![ModeMCU LED Wiring](/images/NodeMCU_LED_Wiring.jpg)

### Step 2 - Connect the DHT sensor to your ESP8266 board

The DHT11 or DHT22 sensors add the ability to sense temperature and humidity.  The DHT22 is a more accurate version of the DHT11.

Disconnect the ESP8266 board from your laptop/workstation before connecting the DHT sensor.

The DHT sensors have 4 connecting pins.  When looking at the front of the sensor (mesh case) with the pins at the bottom, the connections are (left to right):

- +'ve voltage
- Data
- Not used
- Ground

![ModeMCU DHT Wiring](/images/NodeMCU_DHT.jpg)

***
*Quick links :*
[Home](/README.md) - [Compressed Part 1](/compressed/PART1.md) - [Compressed Part 2](/compressed/PART2.md) - [Compressed Part 3](/compressed/PART3.md) - [Compressed Part 4](/compressed/PART4.md)
