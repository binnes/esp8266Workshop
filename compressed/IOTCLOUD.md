*Quick links :*
[Home](/README.md) - [Compressed Part 1](/compressed/PART1.md) - [Compressed Part 2](/compressed/PART2.md) - [Compressed Part 3](/compressed/PART3.md) - [Compressed Part 4](/compressed/PART4.md)
***

# Deploying an application to the IBM Cloud

## Lab Objectives

In this lab you will learn how to deploy a starter application to the IBM Cloud.  You will learn:

- How to access the cloud and set the desired location to work in
- Access the catalog of services and select a boilerplate to deploy
- Deploy a boilerplate to the IBM Cloud

### Introduction

The starter application can take a few minutes to deploy and become available.

Before starting these steps it is assumed you have an IBM Cloud account.

### Step 1 - Accessing the cloud and selecting an appropriate space

Login to your IBM Cloud account and make sure you are working in one of the US South, United Kingdom or Germany locations, as these locations have all the required services we will be using for the rest of the workshop.

If you haven't previously used any of the locations you will need to create a **space** to be able to work in the chosen location.  To do this from the top menu select *Manage* -> *Account* -> *Cloud Foundry Orgs* then click on your mail address to configure your organisation.  Click to **Add a space** then select the region and provide a name for the space.

### Step 2 - Deploy a boilerplate

Open up the [Catalog](https://console.bluemix.net/catalog/?category=blueprints) using the top menu, then select Boilerplates from the left menu under Platform.  Select the Internet of Things Platform Starter.  In the screen presented enter a name for your application - this needs to be a name that is unique to your application, so a good naming convention is to use your initials followed by a name that describes the purpose of the app or the solution name.  This will also form part of the URL for the application.

Next select the location and space you want to deploy the application into . Leave the Selected plan information at the default values then select the **Create** button.

The boilerplate is now deploying a JavaScript application running Node-RED, a low code development environment, an instance of Cloudant NoSQL database and an instance of the Watson Internet of Things Platform.

Please leave this to deploy.

***
*Quick links :*
[Home](/README.md) - [Compressed Part 1](/compressed/PART1.md) - [Compressed Part 2](/compressed/PART2.md) - [Compressed Part 3](/compressed/PART3.md) - [Compressed Part 4](/compressed/PART4.md)
