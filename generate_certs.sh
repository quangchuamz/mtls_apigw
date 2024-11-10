#!/bin/bash

# Create directories for certificates
mkdir -p certs
cd certs

# 1. Create root CA
openssl genrsa -out RootCA.key 4096
openssl req -new -x509 -days 3650 -key RootCA.key -out RootCA.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=Custom CA"

# 2. Create client certificate
openssl genrsa -out my_client.key 2048
openssl req -new -key my_client.key -out my_client.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=client.example.com"

# 3. Sign client certificate with root CA
openssl x509 -req -in my_client.csr -CA RootCA.pem -CAkey RootCA.key \
    -set_serial 01 -out my_client.pem -days 3650 -sha256

# 4. Create truststore
cp RootCA.pem truststore.pem

cd .. 