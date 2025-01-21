
deploy-all: deploy-infrastructure setup-coder

deploy-infrastructure: need-env-HCLOUD_TOKEN
	cd infrastructure/terraform && terraform init && terraform apply

destroy-infrastructure: need-env-HCLOUD_TOKEN
	cd infrastructure/terraform && terraform destroy

init-infrastructure:
	cd infrastructure/terraform && terraform init

setup-coder deploy-coder: kubeconfig
	KUBECONFIG=$$(pwd)/kubeconfig ./coder/setup-coder.sh

destroy-all: destroy-coder destroy-infrastructure

destroy-coder: kubeconfig
	-KUBECONFIG=$$(pwd)/kubeconfig ./coder/destroy-coder.sh

setup-image: need-env-HCLOUD_TOKEN
	./infrastructure/setup-image.sh

.PHONY: kubeconfig
kubeconfig:
	cd infrastructure/terraform && terraform output -raw kubeconfig >../../kubeconfig

need-env-%:
	@[[ -n "$($*)" ]] || (echo "Missing environment variable: \$$$*" && exit 1)
