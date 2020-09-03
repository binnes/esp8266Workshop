@echo off
setlocal
REM Modify the variables below to match your environment - no spaces in values!
SET OPENSSL_BIN=c:\OpenSSL-Win64\bin\openssl
SET COUNTRY_CODE=GB
SET COUNTY_STATE=DOR
SET TOWN=Bournemouth
SET DEVICE_ID=dev01
REM Do not modify below this line

%OPENSSL_BIN% genrsa -aes256 -passout pass:password123 -out rootCA_key.pem 2048
%OPENSSL_BIN% req -new -sha256 -x509 -days 3560 -subj "/C=%COUNTRY_CODE%/ST=%COUNTY_STATE%/L=%TOWN%/O=MOSQUITTO/OU=MOSQUITTO Corporate/CN=Mosquitto Root CA" -extensions v3_ca -set_serial 1 -passin pass:password123 -key rootCA_key.pem -out rootCA_certificate.pem -config ext.cfg
%OPENSSL_BIN% x509 -outform der -in rootCA_certificate.pem -out rootCA_certificate.der

%OPENSSL_BIN% genrsa -aes256 -passout pass:password123 -out mqttServer_key.pem 2048
%OPENSSL_BIN% req -new -sha256 -subj "/C=%COUNTRY_CODE%/ST=%COUNTY_STATE%/L=%TOWN%/O=MOSQUITTO/OU=MOSQUITTO/CN=mosquitto" -passin pass:password123 -key mqttServer_key.pem -out mqttServer_crt.csr
%OPENSSL_BIN% x509 -days 3560 -in mqttServer_crt.csr -out mqttServer_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -extensions v3_req -extfile srvext.cfg -set_serial 11
%OPENSSL_BIN% x509 -outform der -in mqttServer_crt.pem -out mqttServer_crt.der

%OPENSSL_BIN% genrsa -aes256 -passout pass:password123 -out SecuredDev01_key.pem 2048
%OPENSSL_BIN% req -new -sha256 -subj "/C=%COUNTRY_CODE%/ST=%COUNTY_STATE%/L=%TOWN%/O=MOSQUITTO/OU=MOSQUITTO Corporate/CN=%DEVICE_ID%" -passin pass:password123 -key SecuredDev01_key.pem -out SecuredDev01_crt.csr
%OPENSSL_BIN% x509 -days 3650 -in SecuredDev01_crt.csr -out SecuredDev01_crt.pem -req -sha256 -CA rootCA_certificate.pem -passin pass:password123 -CAkey rootCA_key.pem -set_serial 131
%OPENSSL_BIN% rsa -outform der -in SecuredDev01_key.pem -passin pass:password123 -out SecuredDev01_key.key
%OPENSSL_BIN% rsa -in SecuredDev01_key.pem -passin pass:password123 -out SecuredDev01_key_nopass.pem
%OPENSSL_BIN% x509 -outform der -in SecuredDev01_crt.pem -out SecuredDev01_crt.der
endlocal