#!/bin/bash

function createCACert() {
  openssl genrsa -aes256 -out ca.key 4096

  openssl req -new -x509 -sha256 -days 365 -key ca.key -out ca.crt
}

function createCert() {
  cert_name=$1
  openssl genrsa -out $cert_name.key 4096

  openssl req -new -key $cert_name.key -out $cert_name.csr

  echo "authorityKeyIdentifier = keyid,issuer
  basicConstraints = CA:FALSE
  subjectAltName = @alt_names
  [alt_names]
  DNS.1 = portal.catp.globalchain.local" >> $cert_name.ext

  openssl x509 -req \
  -in $cert_name.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -days 365 \
  -sha256 \
  -extfile $cert_name.ext \
  -out $cert_name.crt

  rm $cert_name.ext
  rm $cert_name.csr
}


function_name=$1

case $function_name in
  "createCACert")
    createCACert
    ;;
  "createCert")
    createCert $2
    ;;
  *)
    echo "Function $function_name not found"
    echo "Usage: ./setup.sh [function_name]"
    echo "Functions:"
    echo "  - createCACert"
    echo "  - createCert [name]"
    exit 1
    ;;
esac