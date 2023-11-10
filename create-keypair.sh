#!/bin/bash

openssl genrsa -out key.pem 4096
openssl rsa -in key.pem -pubout -out pub.pem

kubectl create secret generic my-sealed-secrets-key --from-file=key.pem
