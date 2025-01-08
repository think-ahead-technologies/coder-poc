# PoC Coder.com on Talos on Hetzner

Deployment of [Coder.com](https://coder.com/) on Kubernetes using [Talos](https://www.talos.dev/), on [Hetzner](https://console.hetzner.cloud/projects) cloud provider.

## Usage

Run the following (from the root directory of the repo, for simplicity):

1. Setup credentials in your environment
    - `export HCLOUD_TOKEN=<...>`
1. Create image
    - `./infrastructure/setup-image.sh`
1. Deploy infrastructure
    - either run scripts in `infrastructure/manual` in order:
        `./infrastructure/manual/1-create-control-plane.sh`
        `./infrastructure/manual/2-create-workers.sh`
    - or run [Terraform](https://www.hashicorp.com/products/terraform) in `infrastructure/terraform` and export Kubeconfig:
        `pushd infrastructure/terraform`
        `terraform init`
        `terraform apply`
        `terraform output --raw kubeconfig >../../kubeconfig`
        `popd`
1. Export Kubeconfig to local directory:
    - `export KUBECONFIG=../kubeconfig`
1. Deploy coder on the cluster
    - `./coder/setup-coder.sh`
