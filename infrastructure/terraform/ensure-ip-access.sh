#!/bin/bash

# Kubectl commands, run via data resources within the talos module, require
#  access to the cluster. This is blocked by a firewall, which terraform
#  configures to whitelist the user's current IP on deployment. But if that
#  IP changes (e.g. overnight), this script is needed to re-whitelist the
#  new address.
# NB `terraform apply -refresh=false` doesn't solve the issue as the data
#  resources' values are not cached in terraform state.

DNS=$(terraform output -raw coder-dns)
MY_IP=$(curl -s ipv4.canhazip.com)

# Terminate immediately if terraform hasn't been deployed at all
grep -q "No outputs" <(echo "$DNS") && exit 0

# Terminate immediately if the current IP is already whitelisted
hcloud firewall describe $DNS | fgrep -q $MY_IP && exit 0

echo "IP address $MY_IP not allowed by firewall $DNS: whitelisting it..."

DESCRIPTION="Whitelist current user IP address"
hcloud firewall delete-rule --description "$DESCRIPTION" \
    --port any --direction in --source-ips "$MY_IP/32" --protocol tcp \
    $DNS || true
hcloud firewall add-rule --description "$DESCRIPTION" \
    --port any --direction in --source-ips "$MY_IP/32" --protocol tcp \
    $DNS
