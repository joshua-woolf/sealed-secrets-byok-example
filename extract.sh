#!/bin/bash

kubectl -n kube-system get secret sealed-secrets-keyvhvf8 -o json -o=jsonpath="{.data.tls\.crt}" | base64 -d > sealed-secrets-keyvhvf8.cer
kubectl -n kube-system get secret sealed-secrets-keyvhvf8 -o json -o=jsonpath="{.data.tls\.key}" | base64 -d > sealed-secrets-keyvhvf8.key