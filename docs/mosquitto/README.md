# The Mosquitto Broker

An Open Source MQTT broker is available from [Eclipse](https://mosquitto.org).  In this section you will see how to run the Mosquitto broker locally using pre-build Docker images.

## Default configuration

To run the Mosquitto broker with default configuration.  You need to have a system with Docker installed, as specified in the optional content section of the [prerequisites](../part1/PREREQ.md#optional-content-prerequisite){target=_blank}.  The rest of the instructions on this page assume you are working on the system with Docker installed.

To run the mqtt broker and test it locally we will setup a Docker network.  This will allow multiple Docker containers running on the same system to communicate and be able to find each other.

To setup the network enter command ```docker network create mqtt```

To start Mosquitto, open a terminal or command window and enter the command ```docker run -itd -p 1883:1883 -p 9001:9001 --network mqtt --name mosquitto eclipse-mosquitto```

To test it you can also run Node-RED locally in Docker.  To ensure the Node-RED flows are retained when if the Node-RED container is restarted, then a local directory will be mapped into the Node-RED container, so we need to create a local directory to map into the Node-RED container.

- Open a command window on your laptop or workstation where Docker is installed and running.  (Linux or MacOS terminal, Windows CMD or PowerShell window).
- In the command window navigate to the directory where you want to store the Node-RED flow, later we will be adding some additional directories to this location to store MQTT broker content.  I created a directory called mosquitto in my home directory (```mkdir mosquitto`) to store the content
- Create a new directory for Node-RED to use : ```mkdir nodered```
- To run Node-RED run the appropriate command for your operating system :

    - Linux and MacOS

        ``` sh
        docker run -itd -p 1880:1880 -v `pwd`/nodered:/data --network mqtt --name nodered nodered/node-red
        ```

    - Windows Command prompt

        ``` bat
        docker run -itd -p 1880:1880 -v %cd%\nodered:/data --network mqtt --name nodered nodered/node-red
        ```

    - Windows Power shell

         ``` powershell
         docker run -itd -p 1880:1880 -v $PWD\nodered:/data --network mqtt --name nodered nodered/node-red
         ```

    !!! Info
        The parameters for the docker run command used above are:  
        -itd : Run interactively providing a terminal for output and then once running detach from the process  
        -p : Exposes port 1880 inside the container to port 1880 on your system, so Node-RED running in the container can be accessed outside the container and Docker network.  You need this to allow the browser on your system to be able to access Node-RED
        -v : Map a local directory (volume) or file into the container.  Before the colon is the local fully qualified path, after the colon is the path where the directory or file is located in the container file system  
        --network : use the Docker network.  This allows containers to communicate and also provides automatic name resolution based on the --name parameter.  The network must already exist (```docker network ls```)  
        --name : this names the container instance, so the name can be used in docker commands rather than having to use the container ID.  The name is also used to provide network name resolution when --network is used  
        The **\`pwd\`**, **%cd%** or **$PWD** part of the local directory is expanded to represent the fully qualified path of the current directory by the command line interpreter  
        **Note** the **\` \`** characters around pwd are not standard single quotes, they are backward single quotes


You can now access Node-RED from a browser, running on the same system as the Node-RED Docker container, using address [http://localhost:1880](http://localhost:1880){target=_blank}.  Once the Node-RED web user interface is displayed, use the Node-RED top menu to import a Node-RED flow then copy and paste the flow below:

``` JSON
[{"id":"72831a03.1b6adc","type":"mqtt in","z":"59e6aeed.edc8e8","name":"","topic":"#","qos":"2","datatype":"auto","broker":"76932b4.f25f954","x":120,"y":300,"wires":[["14019392.39e7ac"]]},{"id":"8c14d162.b51fb8","type":"mqtt out","z":"59e6aeed.edc8e8","name":"","topic":"","qos":"","retain":"","broker":"76932b4.f25f954","x":430,"y":180,"wires":[]},{"id":"f9e6b867.25c6e","type":"inject","z":"59e6aeed.edc8e8","name":"","props":[{"p":"payload"},{"p":"topic","vt":"str"}],"repeat":"5","crontab":"","once":false,"onceDelay":0.1,"topic":"test","payload":"","payloadType":"date","x":150,"y":180,"wires":[["8c14d162.b51fb8"]]},{"id":"14019392.39e7ac","type":"debug","z":"59e6aeed.edc8e8","name":"","active":true,"tosidebar":true,"console":false,"tostatus":true,"complete":"true","targetType":"full","statusVal":"payload","statusType":"auto","x":410,"y":300,"wires":[]},{"id":"76932b4.f25f954","type":"mqtt-broker","z":"","name":"","broker":"mosquitto","port":"1883","clientid":"","usetls":false,"compatmode":false,"keepalive":"60","cleansession":true,"birthTopic":"","birthQos":"0","birthRetain":"false","birthPayload":"","closeTopic":"","closeQos":"0","closeRetain":"false","closePayload":"","willTopic":"","willQos":"0","willRetain":"false","willPayload":""}]
```

Then deploy it and switch to the debug tab.  You should see a timestamp message arriving every 5 seconds.  The top 2 nodes are publishing the timestamp generated by the Inject node to the test topic.  The bottom 2 nodes subscribe to all topics, then print to the console any messages received.

!!! Info
    If you examine the configuration of the MQTT nodes, you will see the broker name is set to mosquitto, which matches the **--name** property used when starting the Mosquitto broker.  The Docker network provides automatic name resolution using the **--name** property, so the Node-RED application can find the MQTT broker.

This configuration is using the default Mosquitto configuration with no security and no authentication of clients, so not a good solution.

## Controlling Mosquitto configuration

To continue we want to be able to change the configuration, so we are going to setup the Docker container to access local files and directories to manage the configuration.

You are now going to create 3 directories for Mosquitto to use:

``` sh
mkdir config
mkdir data
mkdir log
```

Now create a config file for Mosquitto in the **config** directory called **mosquitto.conf** containing the following:

``` text
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
```

Now the Mosquitto broker needs to use the local configuration.  First we need to stop the running Docker container.

To see what containers are running you use the ```docker ps -a``` command.  You should see an output similar to :

``` text
docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                    PORTS                                            NAMES
6f36d09be224        eclipse-mosquitto   "/docker-entrypoint.…"   28 minutes ago      Up 28 minutes             0.0.0.0:1883->1883/tcp, 0.0.0.0:9001->9001/tcp   mosquitto
0e3e15a37dc9        nodered/node-red    "npm start --cache /…"   29 minutes ago      Up 29 minutes (healthy)   0.0.0.0:1880->1880/tcp                           nodered
```

showing the mosquitto and nodered containers.

To stop a container use the **stop** command.  You can specify either the Container ID from the ps command or the container name:

``` sh
docker stop mosquitto
```

This stops the container, but doesn't remove it.  To remove a container use the **rm** command:

``` sh
docker rm mosquitto
```

When using named containers there can only be a single container with a name.  So you need to remove any previous container before creating a new one.

To start the container using the config and local storage ensure you are in the directory containing the config, data and log folder then use command:

- Linux and Mac:

    ``` sh
    docker run -itd -p 1883:1883 -p 9001:9001 -v `pwd`/config:/mosquitto/config -v `pwd`/data:/mosquitto/data -v `pwd`/log:/mosquitto/log --network mqtt --name mosquitto eclipse-mosquitto
    ```

    !!! Info
        Note the back quotes around pwd in the linux command.  This is not the same as the standard quote.  If in doubt use copy and paste to copy the line above

- Windows Command prompt:

    ``` bat
    docker run -itd -p 1883:1883 -p 9001:9001 -v %cd%\config:/mosquitto/config -v %cd%\data:/mosquitto/data -v %cd%\log:/mosquitto/log --network mqtt --name mosquitto eclipse-mosquitto
    ```

- Windows Power shell

    ``` powershell
    docker run -itd -p 1883:1883 -p 9001:9001 -v $PWD\config:/mosquitto/config -v $PWD\data:/mosquitto/data -v $PWD\log:/mosquitto/log --network mqtt --name mosquitto eclipse-mosquitto
    ```
