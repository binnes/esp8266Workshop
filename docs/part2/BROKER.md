# Choosing an MQTT Broker

At the end of part 1 you deployed the **CloudAMQP** service, which is the MQTT broker you will be using for the rest of this workshop.  However, there are a number of broker options available.

<!-- No trailing punctuation in heading (MD026) -->
<!-- markdownlint-disable MD026 -->
## What is a broker?
<!-- markdownlint-enable MD026 -->

Before discussing the broker options a little further, lets first understand the role of the broker in our application.

MQTT is a messaging protocol that implements a publish/subscribe (pub/sub) model.  This form of messaging disconnects the sender of a message with the consumer(s) of that message.  Think of it like many social media platforms, where you may send a message (publish), but don't know who will read that message.  However, people that have subscribed or follow you will be notified you posted a new message.  This is exactly how pub/sub messaging works.  The sender publishes a message and everyone that has registered (subscribed) to be notified of published messages will be notified when a new message is sent.

In large systems a subscriber doesn't necessarily want to be notified of every published message or doesn't necessarily know who can publish messages, so unlike some social media platforms where you subscribe or follow a specific user, with MQTT you subscribe to *topics* you are interested in.  MQTT also requires all messages to be published to a topic.  A topic is simply a string that provides a context to a published message.  Topics can be given a structure using the **/** character and it is possible to use *wildcards* when subscribing:

- **\#** is the multi-level wildcard
- **+** is the single-level wildcard

given a set of topics for a building management system:

- **environment/temperature/floor1**
- **environment/temperature/floor2**
- **environment/temperature/floor3**
- **environment/lighting/floor1**
- **environment/lighting/floor2**
- **environment/lighting/floor3**
- **building/occupancy/floor1**
- **building/occupancy/floor2**
- **building/occupancy/floor3**
- **building/windows/floor1**
- **building/windows/floor2**
- **building/windows/floor3**

we can subscribe to topics:

- **environment/+/floor1** : to get all floor 1 messages, covering temperature and lighting but not occupancy or window data
- **environment/temperature/+** : to get all temperature data for all floors
- **building/\#** : to get all building data across all floors
- **\#** : to get all messages

The broker is the server in the middle and is:

1. where messages are published
2. where subscriptions are created
3. responsible for notifying subscribers when a message matching one of their subscriptions is published

## Not all brokers are equal

There are a number of Open Source and commercial available options to provide an MQTT broker, however, they have different capabilities, especially when it comes to security and permissions.

Most brokers provide the capability of having a secure connection to the broker using SSL/TLS, the same security used when browsing the web when using https.  However, some brokers allow additional restrictions to be configured to restrict access to topics, so only permitted clients are able to access the restricted topics.

Some brokers have a managed topic space, where the broker defines the topic space and applications can only use the broker defined topics.  The broker will block access to all other topics.  The broker can then manage access and permissions to the topics it defines to provide enhanced security to a solution.  However, this can tie a solution to a specific broker, requiring an application change to move to a different broker.

When choosing which broker to use for a solution there are many different considerations:

- Conformance to standard, is the entire standard fully supported and what version of the standard.  The [MQTT protocol](https://mqtt.org) is an [OASIS standard](https://www.oasis-open.org/committees/tc_home.php?wg_abbrev=mqtt)
- Cost and support.  How much is the broker and what level of support is provided.  Is it a one off cost or a recurring cost?
- Managed service vs self managed?  Do you want a service provider to manage the broker infrastructure and provide a service level agreement, or do you want to manage the broker infrastructure yourself?
- Lock-in or open?  Do you want to use unique features of a specific broker to speed development and provide enhanced capabilities at the cost of being tied to a specific broker or is portability important, avoiding being locked into a specific broker or provider?
- Scalability and resilience.  How important is broker scalability - do you need rapid growth capability or be able to cope with sudden bursts of traffic?  How many connected device will there be and what is the messages per second throughput required to support your application?  Do you want multi-cloud support? How does a system failure impact clients? Do you need zero-downtime maintenance capability?
- Location?  Do you need regional locations for data privacy regulations?
- Security.  What level of security do you need for your solution.  Secured connectivity, client certificates, permissions to access topics.

    !!! Info
        It is possible to implement security outside the broker functionality, such as encrypting or signing messages then using standard MQTT to deliver the message.

The choice of broker may impact the implementation of your solution, so is worth thinking about before you get too far with the implementation.  

The MQTT site provides a [list of software](https://mqtt.org/software/) supporting the MQTT protocol.
