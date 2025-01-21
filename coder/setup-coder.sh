#!/bin/bash

cd $(dirname $0)

trap ctrl_c INT

function ctrl_c() {
    echo "Received interrupt signal. Exiting." >&2
    exit 1
}

echo "Installing coder on existing Kubernetes cluster. This script is idempotent." >&2

# Inject DNS credentials as a Kubernetes secret
cat cluster-issuer-secret.yaml | ENCODED_SECRET="$(echo "$HETZNER_DNS_API_TOKEN" | base64)" envsubst | kubectl apply -f -

kubectl apply -f cluster-issuer.yaml

helm repo add jetstack https://charts.jetstack.io
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.3 \
  --set crds.enabled=true

helm repo add cert-manager-webhook-hetzner https://vadimkim.github.io/cert-manager-webhook-hetzner
helm upgrade --install \
    cert-manager-webhook-hetzner \
    cert-manager-webhook-hetzner/cert-manager-webhook-hetzner \
    --namespace cert-manager \
    --set groupName=think-ahead.dev
    # --set secretName[0]=hetzner-secret

echo "Setting up nginx ingress"
helm upgrade --wait --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."load-balancer\.hetzner\.cloud/location"=nbg1 \
  --set controller.service.annotations."load-balancer\.hetzner\.cloud/name"=coder-load-balancer

LB_IP=$(hcloud load-balancer list | tail -n +2 | awk '{print $4}' | head -1)
if [ -z "$LB_IP" ]; then
    echo "Error: no load balancer found. Could your kubectl be invalid?" >&2
    exit 1
fi

# Install PostgreSQL
helm repo add bitnami https://charts.bitnami.com/bitnami
helm upgrade coder-db bitnami/postgresql \
    --install \
    --create-namespace \
    --namespace coder \
    --set auth.username=coder \
    --set auth.password=coder \
    --set auth.database=coder \
    --set persistence.size=10Gi

kubectl apply -k storage-class

kubectl create secret generic coder-db-url --dry-run=client -n coder \
  --from-literal=url="postgres://coder:coder@coder-db-postgresql.coder.svc.cluster.local:5432/coder?sslmode=disable" \
  -o yaml | kubectl apply -f -

helm repo add coder-v2 https://helm.coder.com/v2

helm upgrade coder coder-v2/coder \
    --install \
    --namespace coder \
    --values coder-values.yaml \
    --set coder.env[0].value="http://$LB_IP" \
    --version 2.18.2

kubectl apply -f ingress.yaml

echo
echo "Coder set up. Once it is ready, you can access it at: http://$LB_IP/"