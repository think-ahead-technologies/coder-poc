
deploy-all: deploy-infrastructure setup-coder

deploy-infrastructure: need-env-HCLOUD_TOKEN need-env-HETZNER_DNS_API_TOKEN
	cd infrastructure/terraform \
	&& export TF_VAR_HCLOUD_TOKEN=$$HCLOUD_TOKEN \
	&& ./ensure-ip-access.sh \
	&& terraform init \
	&& terraform apply -auto-approve

destroy-infrastructure: need-env-HCLOUD_TOKEN
	cd infrastructure/terraform \
	&& ./ensure-ip-access.sh \
	&& terraform destroy

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
