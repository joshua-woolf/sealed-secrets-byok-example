#!/bin/bash

# Create a k8s cluster to run the example on using kind:

CLUSTER_NAME=secrets

kind create cluster --name "$CLUSTER_NAME"
kubectl config set-context "kind-$CLUSTER_NAME"

# Create a key pair:

DATE=$(date '+%Y%m%d')
KEY_NAME="sealed-secrets-key-$DATE"
PRIVATE_KEY_FILE_NAME="$KEY_NAME.key"
PUBLIC_KEY_FILE_NAME="$KEY_NAME.crt"

openssl req -x509 -days 1 -nodes -newkey "rsa:4096" -keyout "$PRIVATE_KEY_FILE_NAME" -out "$PUBLIC_KEY_FILE_NAME" -subj "/CN=sealed-secret/O=sealed-secret"

# Create a secret for the key pair and apply it to the k8s cluster:

NAMESPACE="kube-system"

kubectl -n "$NAMESPACE" create secret tls "$KEY_NAME" --cert="$PUBLIC_KEY_FILE_NAME" --key="$PRIVATE_KEY_FILE_NAME"
kubectl -n "$NAMESPACE" label secret "$KEY_NAME" "sealedsecrets.bitnami.com/sealed-secrets-key=active"

## Install the sealed secrets controller:

helm repo add "sealed-secrets" "https://bitnami-labs.github.io/sealed-secrets" --force-update
helm install "sealed-secrets" "sealed-secrets/sealed-secrets" --namespace "$NAMESPACE" --set secretName="$KEY_NAME" --wait

# Create a secret from a file on disk:

SECRET_NAME="example-secret"
SECRET_SOURCE_FILE_NAME="$SECRET_NAME.txt"
SECRET_FILE_NAME="$SECRET_NAME.yaml"

echo -n bar | kubectl create secret generic "$SECRET_NAME" --dry-run="client" --from-file="$SECRET_SOURCE_FILE_NAME" -o "yaml" >"$SECRET_FILE_NAME"

# Seal the secret using kubeseal and apply it to the k8s cluster:

SEALED_SECRET_FILE_NAME="sealed-$SECRET_FILE_NAME"

kubeseal --secret-file "$SECRET_FILE_NAME" --sealed-secret-file "$SEALED_SECRET_FILE_NAME" --cert "$PUBLIC_KEY_FILE_NAME" --format "yaml" --scope "cluster-wide"

kubectl create namespace "$SECRET_NAME"
kubectl apply -f "$SEALED_SECRET_FILE_NAME" -n "$SECRET_NAME"

# Wait for the sealed secret to be unsealed and read it from the cluster.

while true; do
  SECRET=$(kubectl get secret $SECRET_NAME -n $SECRET_NAME 2>/dev/null)
  if [ -z "$SECRET" ]; then
    echo "Secret '$SECRET_NAME' not found. Retrying in a second..."
    sleep 1
  else
    kubectl get secret "$SECRET_NAME" -n "$SECRET_NAME" -o "json" | jq -r '.data."example-secret.txt"' | base64 -d
    break
  fi
done

# Cleanup

rm "$SECRET_FILE_NAME"
rm "$SEALED_SECRET_FILE_NAME"
rm "$PRIVATE_KEY_FILE_NAME"
rm "$PUBLIC_KEY_FILE_NAME"

kind delete cluster --name "$CLUSTER_NAME"
