#!/bin/bash

kubectl create secret generic my-secret --from-file=secret.txt
