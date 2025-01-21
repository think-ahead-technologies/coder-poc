# PoC Coder.com on Talos on Hetzner

Deployment of [Coder.com](https://coder.com/) on Kubernetes using [Talos](https://www.talos.dev/), on [Hetzner](https://console.hetzner.cloud/projects) cloud provider.

## Usage

### Deployment

Run the following (from the root directory of the repo, for simplicity):

1. Setup credentials in your environment
    - `export HCLOUD_TOKEN=<...>`
    - `export HETZNER_DNS_API_TOKEN=<...>`
1. Create image
    - `./infrastructure/setup-image.sh`
    - _OR_ `make setup-image`
1. Deploy infrastructure
    - either run scripts in `infrastructure/manual` in order:
        `./infrastructure/manual/1-create-control-plane.sh`
        `./infrastructure/manual/2-create-workers.sh`
    - or run [Terraform](https://www.hashicorp.com/products/terraform) in `infrastructure/terraform` and export Kubeconfig:
        - `pushd infrastructure/terraform`
        - `terraform init`
        - `terraform apply`
        - `terraform output --raw kubeconfig >../../kubeconfig`
        - `popd`
    - terraform code above can alternatively be run with: `make deploy-infrastructure`
1. Export Kubeconfig to local directory:
    - `export KUBECONFIG=../kubeconfig`
1. Deploy coder on the cluster
    - `./coder/setup-coder.sh`
    - _OR_ `make setup-coder`
1. Access Coder at the URL of the load balancer (output by the above script).
1. Create a Coder Template
    - use [coder/workspace-template.tf](workspace-template.tf) for the Terraform source code
1. Create a Workspace based on your new Template
1. Success!

# Destroying a deployment

You can spin down an existing Coder deployment simply:
1. Setup credentials as with creation
    - `export HCLOUD_TOKEN=<...>`
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