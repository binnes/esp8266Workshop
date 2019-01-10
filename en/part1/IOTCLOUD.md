*Quick links :*
[Home](/README.md) - [**Part 1**](../part1/README.md) - [Part 2](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
***
**Part 1** - [Setup](PREREQ.md) - [First App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [DHT](DHT.md) - [**Cloud**](IOTCLOUD.md)
***

# Deploying an application to the IBM Cloud

## Lab Objectives

In this lab you will learn how to deploy a starter application to the IBM Cloud.  You will learn:

- How to access the cloud and set the desired location to work in
- Access the catalog of services and select a Starter Kit to deploy
- Deploy a Starter Kit to the IBM Cloud

## Introduction

Before finishing part 1 you should deploy the starter application that we will be using in Part 2, as this can take a few minutes to deploy and become available.

Before starting these steps it is assumed you have completed the steps in the [prerequisite section](PREREQ.md) and have an active IBM Cloud account.

### Step 1 - Accessing the cloud and selecting an appropriate space

[Login](https://cloud.ibm.com) to your cloud account and make sure you are working in one of the US South, United Kingdom or Germany locations, as these locations have all the required services we will be using for the rest of the workshop.

If you haven't previously used any of the locations you will need to create a **space** to be able to work in the chosen location.  To do this from the top menu select *Manage* -> *Account* -> *Cloud Foundry Orgs* then click on your mail address to configure your organisation.  Click to **Add a space** then select the region and provide a name for the space.

### Step 2 - Deploy a Starter Kit

Open up the Catalog using the top menu, then select Starter Kits from the left menu, then select the Internet of Things Platform Starter.  In the screen presented enter a name for your application - this needs to be a name that is unique to your application, so a good naming convention is to use your initials followed by a name that describes the purpose of the app or the solution name.  This will also form part of the URL for the application.

Next select the location and space you want to deploy the application into . Leave the Selected plan information at the default values then select the **Create** button.

The Starter Kit is now deploying a JavaScript application running Node-RED, a low code development environment, an instance of Cloudant NoSQL database and an instance of the Watson Internet of Things Platform.

Please leave this to deploy - now is a good time to go for a break.

***
*Quick links :*  
**Part 1** - [Setup](PREREQ.md) - [First App](FIRSTAPP.md) - [WIFI](WIFI.md) - [LED](LED.md) - [DHT](DHT.md) - [**Cloud**](IOTCLOUD.md)
***
[Home](/README.md) - [**Part 1**](../part1/README.md) - [Part 2](../part2/README.md) - [Part 3](../part3/README.md) - [Part 4](../part4/README.md)
