# Security for IoT and Internet traffic

Any device that uses the Internet for communication needs to have some level of protection.  Even if you think the data being sent isn't sensitive and doesn't need to be secured, there have been numerous instances where hackers have used insecure IoT devices to launch cyber attacks.

Also you may not be aware how the sensor data is being used, so whilst it may not appear to be sensitive data, but if a hacker interfered with the data it may impact the business, as other business process may be triggered by the IoT data.

## What do we mean by security

Security for internet applications is huge topic, which we cannot cover in depth in this workshop, but we will look at some of the basics and what we can do to secure an IoT solution.

The first questions to consider is "what is security?".  Security is a very loaded term, so lets look at some of the areas:

### Privacy

When sending data over the internet it can often contain sensitive information, such as a password or personal information, which must not be visible to anyone able to monitor network traffic.

### Trust

When using the Internet you want to be able to trust the connection and be assured that the server actually belongs to the organisation you think it does.  So when doing online banking or shopping online you want to be able to verify you are communicating with the correct server application.

### Data Integrity

You want to be assured that data you send is received unaltered and similarly data you receive is what was actually sent.  There is no one able to capture and alter data as it crosses the Internet.

## Encryption

Encryption technology allows data to be encrypted, so when sent across the Internet ensuring only those with access to the secrets, or keys, needed to decrypt the data can get access to the original data.

There are numerous ways to encrypt data and we will look at 2 different technologies that are used to secure internet traffic.

### Symmetric Encryption

![Symmetric encryption](../images/symmetric.png)

Symmetric encryption algorithms take data, often called plaintext, and use a secret, or key, to generate ciphertext, which is a representation of the data where the content can no longer be seen.  Ciphertext makes the content look like a random collection of characters.

Symmetric encryption uses the same secret, or key, or decrypt the ciphertext back into the plaintext version of the data.

Some common symmetric encryption algorithms you may encounter are : AES, Blowfish, RC4, DES, 3DES

### Asymmetric Encryption

![Asymmetric encryption](../images/asymmetric.png)

Asymmetric encryption does the same as Symmetric encryption, where plaintext is converted to ciphertext.  But with asymmetric encryption, the key used to encrypt data is not the same as the key needed to decrypt the data.

Asymmetric encryption uses a pair of related keys, where a message encrypted by one key can only be decrypted by the other key.  Once of the keys is kept secure, as the private key, but the other key is made public and distributed to anyone that may want to communicate with the owner of the private key.

Another advantage with asymmetric encryption is whoever is using the public key knows that they are communicating with whoever has the private key.  As private keys are never distributed, then asymmetric encryption gives whoever is using the public key a level of confidence about the identity of the private key holder.

## Digital Signatures

A digital signature allows data to remain unencrypted, but has a "signature" associated with it.  The signature does 2 things:

- Ensures the document hasn't been modified after being signed
- Captures the identity of the signer of the document

![Digital Signature](../images/digitalSignature.png)

A digital signature relies on asymmetric encryption and a hashing algorithm.  The hashing algorithm is a way to produce a fixed length output based on an input of any length.  The output is often called the digest.

The hashing algorithm will always generate the same output for a given input, however, it is a 1 way operation.  There is no way to regenerate the original input from the output.  A hashing algorithm must also ensure that the original document cannot be altered and still produce the same hash output.

To digitally sign a document the digest is generated from the hashing algorithm, then the digest is encrypted using the private key of the signer.  This is then associated with the document.

To verify the signature you simply pass the document through the hash algorithm to generate the digest.  Then using the public key of the signer you decrypt the digital signature.  The decrypted signature should contain the same has as you generated, which shows the document hasn't been altered since being signed.  You are also assured of the identity of the document signer, as they had to have the private key to be able to encrypt the document hash.

## Certificates

- Chains
- Root Certificate Authority

## SSL / TLS

- difference
- handshake
