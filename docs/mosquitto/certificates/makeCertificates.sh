#!/bin/bash

# Modify the variables below to match your environment - no spaces in values!
OPENSSL_BIN=openssl
COUNTRY_CODE=GB
COUNTY_STATE=DOR
TOWN=Bournemouth
DEVICE_ID=dev01
# Do not modify below this line

eval $OPENSSL_BIN genrsa -aes256 -passout pass:password123 -out rootCA_key.pem 2048
eval $OPENSSL_BIN req -new -sha256 -x509 -days 3560 -subj \"/C=$COUNTRY_CODE/ST=$COUNTY_STATE/L=$TOWN/O=MOSQUITTO/OU=MOSQUITTO Corporate/CN=Mosquitto Root CA\" -extensions v3_ca -set_serial 1 -passin pass:password123 -key rootCA_key.pem -out rootCA_certificate.pem -config ext.cfg
eval $OPENSSL_BIN x509 -outform der -in rootCA_certificate.pem -out rootCA_certificate.der
xxd -i rootCA_certificate.der rootCA_certificate.der.h

eval $OPENSSL_BIN genrsa -aes256 -passout pass:password123 -out mqttServer_key.pem 2048
eval $OPENSSL_BIN req -new -sha256 -subj \"/C=$COUNTRY_CODE/ST=$COUNTY_STATE/L=$TOWN/O=MOSQUITTO/OU=MOSQUITTO Corporate/CN=mosquitto\" -passin pass:password123 -key mqttServer_key.pem -out mqttServer_crt.csr
eval $OPENSSL_BIN x509 -days 3560 -in mqttServer_crt.csr -out mqttServer_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -extensions v3_req -extfile srvext.cfg -set_serial 11
eval $OPENSSL_BIN x509 -outform der -in mqttServer_crt.pem -out mqttServer_crt.der
xxd -i mqttServer_crt.der mqttServer_crt.der.h

eval $OPENSSL_BIN genrsa -aes256 -passout pass:password123 -out SecuredDev01_key.pem 2048
eval $OPENSSL_BIN req -new -sha256 -subj \"/C=$COUNTRY_CODE/ST=$COUNTY_STATE/L=$TOWN/O=MOSQUITTO/OU=MOSQUITTO Corporate/CN=$DEVICE_ID\" -passin pass:password123 -key SecuredDev01_key.pem -out SecuredDev01_crt.csr
eval $OPENSSL_BIN x509 -days 3650 -in SecuredDev01_crt.csr -out SecuredDev01_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -set_serial 131
eval $OPENSSL_BIN rsa -outform der -in SecuredDev01_key.pem -passin pass:password123 -out SecuredDev01_key.key
eval $OPENSSL_BIN rsa -in SecuredDev01_key.pem -passin pass:password123 -out SecuredDev01_key_nopass.pem
eval $OPENSSL_BIN x509 -outform der -in SecuredDev01_crt.pem -out SecuredDev01_crt.der
xxd -i SecuredDev01_crt.der SecuredDev01_crt.der.h