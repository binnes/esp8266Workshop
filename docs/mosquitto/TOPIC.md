# Access control of Topics

The final area we will cover with the Mosquitto broker is topic security.  Mosquitto allows you to add access control to topics, so a user of client can only access certain topics.

For any topic the permissions can be :

- **read** : You can subscribe to the topic
- **write** : You can publish to the topic
- **readwrite** : You can both publish and subscribe to the topic.  This is the default value.

When access control is enabled, then all topics are automatically blocked unless explicitly allowed.  When creating rules for topic permissions then the MQTT **+** (single level) and **#** (multi-level) wildcards can be used, exactly the same way as they are used when subscribing to topics.

There are 2 additional substitutions that can be used:

- %c : to match the client ID of the connected client
- %u : to match the username of the connected client

when using these substitutions they must be the only text for a given level of a topic.

E.g ```device/%c/status``` is valid, but ```device_%c/status``` is not valid.

## Enabling topic access control

To enable access control you simply configure a file to contain the access control definitions in the Mosquitto configuration file:

```text
acl_file /mosquitto/config/acl.cfg
```

then the access control rules can be added to the acl.cfg file.

## Access control rules

Access control rules take the form:

```text
topic [read|write|readwrite] <topic>
```

The access type parameter can be omitted if the topic doesn't contain any spaces and the default permission of readwrite will be used.

If you want to define a set of rules for a specific user then the

```text
user <username>
```

then all rules after this line will be for the specified user until another **user** line is encountered.

When using one of the %u or %c substitutions then the configuration changes to use the **pattern** action.  Patterns are not user specific and will apply to all connections, even if defined after a user rule:

```text
pattern [read|write|readwrite] <topic contining substitution>
```

You can add comments to the configuration file using a **#** character as the first character on a line

## Sample access control configuration

To demonstrate how topic access control be used we will alter the ESP8266 application to publish environmental data to topic ```dev01/status```, so the 3 topics the application uses are:

```C
#define MQTT_TOPIC "dev01/status"
#define MQTT_TOPIC_DISPLAY "dev01/display"
#define MQTT_TOPIC_INTERVAL "dev01/interval"
```

The access control we want to add is:

- only the device can publish to the status topic starting with its own client ID :  <client ID\>/status
- only the device can receive messages published to topics display and interval starting with its own client ID : <client ID\>/interval and <client ID\>/display
- only client dev02 (the Node-RED application) can receive status messages sent by other devices
- only client dev02 can send display and interval messages to change state of other devices

With these requirements the acl.cfg file would look like:

```text
# Access control file

pattern readwrite %c/status
pattern read %c/display
pattern read %c/interval

user dev02
topic read +/status
topic write +/display
topic write +/interval
```

!!! Info
    As we have tied the username and the client ID in the broker config the access control rules can use either %u or %c, as both values are the same for all broker connections to our broker.
