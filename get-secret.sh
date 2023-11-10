#!/bin/bash

kubectl get secret my-secret -o json | jq -r '.data."secret.txt"' | base64 --decode
