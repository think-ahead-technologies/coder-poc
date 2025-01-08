#!/bin/bash

cd $(dirname $0)

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

kubectl create secret generic coder-db-url --dry-run -n coder \
  --from-literal=url="postgres://coder:coder@coder-db-postgresql.coder.svc.cluster.local:5432/coder?sslmode=disable" \
  -o yaml | kubectl apply -f -

helm repo add coder-v2 https://helm.coder.com/v2

helm upgrade coder coder-v2/coder \
    --install \
    --namespace coder \
    --values coder-values.yaml \
    --version 2.18.2

# TODO figure out ingress

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.annotations."load-balancer\.hetzner\.cloud/location"=nbg1

# NB possibly access Coder on localhost:8080 after setting up port-forwarding 8080->8080.