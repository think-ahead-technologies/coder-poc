#!/bin/bash

# See https://www.talos.dev/v1.9/talos-guides/install/cloud-platforms/hetzner/#create-the-control-plane-nodes

cd $(dirname $0)

# Generated using image.sh in this same directory
export IMAGE_ID=209996745
export SERVER_TYPE=cax11
export LOAD_BALANCER_IP_OR_DNS=167.235.109.127

function create_load_balancer {
	hcloud load-balancer create --name controlplane --network-zone eu-central --type lb11 --label 'type=controlplane'

	hcloud load-balancer add-service controlplane \
	    --listen-port 6443 --destination-port 6443 --protocol tcp

	hcloud load-balancer add-target controlplane \
	    --label-selector 'type=controlplane'
}


function generate_config {
	talosctl gen config talos-k8s-hcloud-tutorial https://$LOAD_BALANCER_IP_OR_DNS:6443 \
	    --with-examples=false --with-docs=true
	talosctl validate --config controlplane.yaml --mode cloud
}

function create_control_plane_machines {
	hcloud server create --name talos-control-plane-1 \
	    --image ${IMAGE_ID} \
	    --type $SERVER_TYPE --location hel1 \
	    --label 'type=controlplane' \
	    --user-data-from-file controlplane.yaml

	hcloud server create --name talos-control-plane-2 \
	    --image ${IMAGE_ID} \
	    --type $SERVER_TYPE --location fsn1 \
	    --label 'type=controlplane' \
	    --user-data-from-file controlplane.yaml

	hcloud server create --name talos-control-plane-3 \
	    --image ${IMAGE_ID} \
	    --type $SERVER_TYPE --location nbg1 \
	    --label 'type=controlplane' \
	    --user-data-from-file controlplane.yaml
}

function bootstrap_etcd {
	control_ip_1=$(hcloud server list | grep talos-control-plane | awk '{print $4}' | head -1)
	talosctl --talosconfig talosconfig config endpoint $control_ip_1
	talosctl --talosconfig talosconfig config node $control_ip_1
	talosctl --talosconfig talosconfig bootstrap

	talosctl --talosconfig talosconfig -n $control_ip_1 get members
	talosctl --talosconfig talosconfig kubeconfig .
}

function add_ccm {
	control_ips=$(hcloud server list | grep talos-control-plane | awk '{print $4}' | paste -sd "," -)
	talosctl --talosconfig talosconfig patch machineconfig --patch-file controlplane-patch-ccm.yaml --nodes $control_ips
    kubectl -n kube-system create secret generic hcloud --from-literal=token=$(echo "$HCLOUD_TOKEN")
    helm repo add hcloud https://charts.hetzner.cloud
    helm repo update hcloud
    helm install hccm hcloud/hcloud-cloud-controller-manager -n kube-system
}

add_ccm
