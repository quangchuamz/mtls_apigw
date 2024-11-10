#!/bin/bash

# Create directories for certificates
mkdir -p certs
cd certs

# 1. Generate CA private key and certificate
echo "Generating CA certificate..."
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 1825 -out ca.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=Custom CA"

# 2. Generate server (API Gateway) private key and CSR
echo "Generating server certificate..."
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=api-gateway.example.com"

# 3. Generate server certificate signed by CA
openssl x509 -req -in server.csr -CA ca.pem -CAkey ca.key \
    -CAcreateserial -out server.pem -days 365 -sha256

# 4. Generate client private key and CSR
echo "Generating client certificate..."
openssl genrsa -out client.key 2048
openssl req -new -key client.key -out client.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=client.example.com"

# 5. Generate client certificate signed by CA
openssl x509 -req -in client.csr -CA ca.pem -CAkey ca.key \
    -CAcreateserial -out client.pem -days 365 -sha256

# 6. Create combined client certificate and key file (some clients need this)
cat client.pem client.key > client-combined.pem

echo "Certificate generation complete!"
echo "Generated files:"
ls -l

cd .. 