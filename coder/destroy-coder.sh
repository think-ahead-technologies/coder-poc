#!/bin/bash

cd $(dirname $0)

helm delete coder-db --namespace coder
helm delete coder --namespace coder
kubectl delete secret coder-db-url --namespace coder
kubectl delete -k storage-class
