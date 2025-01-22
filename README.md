# PoC Coder.com on Talos on Hetzner

Deployment of [Coder.com](https://coder.com/) on Kubernetes using [Talos](https://www.talos.dev/), on [Hetzner](https://console.hetzner.cloud/projects) cloud provider.

## Usage

### Deployment

Run the following (from the root directory of the repo, for simplicity):

1. Setup credentials in your environment
    - `export HCLOUD_TOKEN=<...>`
    - `export TF_VAR_HCLOUD_TOKEN=<...>`
    - `export HETZNER_DNS_API_TOKEN=<...>`
1. Create image (only needs to be run once)
    - `./infrastructure/setup-image.sh`
    - _OR_ `make setup-image`
1. Deploy infrastructure
    - (_recommended_) deploy using [Terraform](https://www.hashicorp.com/products/terraform) via `make deploy-infrastructure`
    - you may instead run `terraform` manually:
        - `pushd infrastructure/terraform`
        - `terraform init`
        - `terraform apply`
        - `./ensure-ip-access.sh`
        - `terraform output --raw kubeconfig >../../kubeconfig`
        - `popd`
    - [Manual scripts](/infrastructure/manual/) also exist, but no guarantees are made of these functioning fully:
        `./infrastructure/manual/1-create-control-plane.sh`
        `./infrastructure/manual/2-create-workers.sh`
1. Point Kubeconfig to repo root directory:
    - `export KUBECONFIG=$(pwd)/kubeconfig`
1. Deploy coder on the cluster
    - `make setup-coder`
    - _OR_ `./coder/setup-coder.sh`
    - _NOTE_: if run too soon after deployment, some steps may fail. In this case, simply rerun the script.
1. Access Coder at the URL of the load balancer (output by the above script).
1. Create a Coder Template
    - use [coder/workspace-template.tf](workspace-template.tf) for the Terraform source code
1. Create a Workspace based on your new Template
1. Success!

### Destroying a deployment

You can spin down an existing Coder deployment simply:
1. Setup credentials as with creation
    - `export HCLOUD_TOKEN=<...>`
    - `export TF_VAR_HCLOUD_TOKEN=<...>`
    - `export HETZNER_DNS_API_TOKEN=<...>`
1. Destroy Coder resources within Terraform
    - `./coder/destroy-coder.sh`
    - _or_ `make destroy-coder`
    - Note that this does not destroy 'side-effect' resources like active workspaces
1. Destroy the base infrastructure
    - `pushd infrastructure/terraform`
    - `terraform init`
    - `terraform destroy`
    - `popd`
    - _OR_ `make destroy-infrastructure`