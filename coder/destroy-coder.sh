#!/bin/bash

cd $(dirname $0)

# LB_IP=$(hcloud load-balancer list | tail -n +2 | head -1 | awk '{print $4}')
# hcloud firewall delete-rule --description "Allow ingress from load balancer" \
#     --port any --direction in --source-ips "$LB_IP/32" --protocol tcp \
#     coder.thinkahead.dev

echo "Removing ingress-related resources..."
helm delete ingress-nginx --namespace ingress-nginx
kubectl delete -f ingress.yaml

echo "Removing Coder itself..."
helm delete coder-db --namespace coder
helm delete coder --namespace coder
kubectl delete secret coder-db-url --namespace coder
kubectl delete -k storage-class

echo "Removing cert-manager and related resources..."
helm delete cert-manager --namespace cert-manager
helm delete cert-manager-webhook-hetzner --namespace cert-manager
kubectl delete -f cluster-issuer.yaml
kubectl delete -f cluster-issuer-secret.yaml