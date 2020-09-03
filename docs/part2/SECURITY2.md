# Additional Security considerations

Internet of Things security is a big topic that covers many different areas, too many to cover in depth in this workshop, but here are a few areas that need to be considered when designing a solution

## Physical security

IoT devices are often placed outside a secured area, within a workplace or even in a public space.  This means physical security needs to be considered.  A solution can be disrupted in a number of ways:

- loss of power so device doesn't report readings
- tampering with device to cause incorrect readings
- device being destroyed or stolen

The design of the device and the location of the device can reduce the chances for a device to be interfered with.

If a device is stolen or can be accessed in place, then the security of device storage also needs to be considered.  

The ESP8266 is an inexpensive device that lacks features to secure internal storage, such as secure boot, encrypted or protected flash memory, application code verification/encryption.  If you have physical access to an ESP8266 device you can read the memory of the device, so can access anything on a filesystem and the application binary.  You can also replace the application code running on the device.  This is a big security exposure, so whilst good to learn about IoT and use it for hobby projects the ESP8266 is probably not a good choice for a commercial solution.

There are a number of devices and components available on the market that have security built in to provide an enhanced level of security to prevent local attacks.  If the device is physically accessed then the content of memory and storage is protected and code cannot be read or replaced without having the appropriate security keys.  Examples of device security can be seen from [Texas Instruments](https://www.ti.com/technologies/security/overview.html){target=_blank} and [STMicroelectronics](https://www.st.com/content/st_com/en/stm32trust.html){target=_blank}.

## Client Validation

In the previous section you added TLS security to the MQTT connection.  This allows the client to verify the server identity.  However, the server does not validate the identity of the client as part of the secured connection.

Different brokers provide different options for securing the client connections.  

The free level of service with the cloudAMQP service doesn't allow you to configure client security other than the username and password, but the paid plans do allow client certificates to be used.

Some of the options for managing client access to MQTT brokers are:

- client user ID and password.  Sometimes this can be a single identity that all clients must provide, or it can be a unique id and password for each client
- client certificates.  This adds client certificates to the TLS handshake, where the client must also present a X.509 certificate, signed by a trusted authority.  The client certificate should contain a unique identifier for the client
- client permissions.  Some brokers allow access controls to be configured, to restrict the topics a client can publish or subscribe to.  This can help limit the exposure in case of a security breach

In addition to the features offered by brokers, it is also possible to add encryption to the message content.  You can use the same asymmetric encryption algorithms to sign or encrypt messages being sent over a MQTT connection.  The server can then be assured that the device sending the message has access to the private key for the client.  However, this requires the private key to be secure even when a device is stolen or someone has gained physical access to the device.

## Additional content

If you want to explore security features available in the Mosquitto broker, then there is a section in the [Additional Resources](../mosquitto/README.md){target=_blank} section, where you are taken through:

- Deploying the Mosquitto broker on a local system using Docker
- Creating a local, self-signed Certificate Authority using OpenSSL
- Creating both server and client certificates using OpenSSL
- Configuring the server to use TLS connections
- Configuring client logon with username and password
- Managing client access to the topic space

You are not required to complete this extra section, but it shows how to access some additional features available from brokers.  It is also a useful resource if you want to set up a local broker for home automation or other local projects.
