# Workshop Summary

You have now completed the workshop.  I hope you enjoyed working through the various sections building up to the final solution.

Hopefully you now have a good understanding of some of the work needed to create an IoT solution.  In this workshop you:

- Constructed the hardware circuit using an ESP8266 NodeMCU board with a DHT sensor and RGB LED
- Implemented the embedded C program for the ESP8266 board:
  - Connected to local WiFi network
  - Handled communication with the connected DHT sensor and LED
  - Obtained the current time using NTP server
  - Connected securely to the cloudAMQP MQTT Broker
  - Sent and received JSON messages over MQTT
  - Implemented the Logistic Regression function with the parameters from the trained model
- Deployed an application and services on the IBM Cloud
- Configured the CloudAMQP MQTT Broker to securely communicate with your ESP8266 board and Node-RED application
- Implemented Node-RED flows to work with IoT data, store data in a Cloudant NoSQL database and send commands to the ESP8266 board
- Implemented a dashboard in Node-RED to visualise the IoT data and configure behaviour of the ESP8266 board
- Worked in Watson Studio to access database records, containing data from the ESP8266 device
- Inspected the training data in Watson Studio
- Trained a classifier model in Watson Studio using data from the ESP8266
- Validated the classifier model in Watson Studio
- Extracted the model parameters from the Jupyter Notebook and implemented the model on the ESP8266 to provide real-time classification of IoT data

This is just a taster of the many skills needed to implement an IoT solution.   Below you will find links to sources of continued learning, where you can explore in more depth some of the topics you touched in this workshop:

## Coursera courses provided by IBM

IBM has created a number of courses on the Coursera learning platform.  These courses can be taken for free (the audit course option) or can be purchased.  When auditing a course you get access to the learning material, but cannot take the marked assessments and do not earn the course certificate or IBM Open Badge.  If you choose to purchase the course then you need to complete all the marked assessments and once passes, you will earn a Coursera course certificate and optionally an IBM Open Badge, showing you have completed the course.  
  
There is a Data Science specialisation, which comprises of 3 courses and a capstone project:

[Advanced Data Science with IBM Specialization](https://www.coursera.org/specializations/advanced-data-science-ibm)

- [Fundamentals of Scalable Data Science](https://www.coursera.org/learn/ds)
- [Advanced Machine Learning and Signal Processing](https://www.coursera.org/learn/advanced-machine-learning-signal-processing)
- [Applied AI with DeepLearning](https://www.coursera.org/learn/ai)

To go beyond the basics of Node-RED there is additional material available on the [Node-RED website](https://nodered.org) and there is a [workshop](https://github.com/binnes/moreNodeRedWorkshop) to learn more about Node-RED features
