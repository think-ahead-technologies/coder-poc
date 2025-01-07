#!/bin/bash

export IMAGE_ID=209996745
export SERVER_TYPE=cax31
export REGION=nbg1

# Don't necessarily need this (TODO)
export LOAD_BALANCER_IP_OR_DNS=167.235.109.127


function create_worker_node {
	hcloud server create --name talos-worker-1 \
	    --image ${IMAGE_ID} \
	    --type $SERVER_TYPE --location $REGION \
	    --label 'type=worker' \
	    --user-data-from-file worker.yaml
}

function config_worker_node {
	
}
