.PHONY: install
UNAME := $(shell uname)
ifeq ($(UNAME),Linux)
	TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.10.2/terraform_0.10.2_linux_amd64.zip"
endif
ifeq ($(UNAME),Darwin)
	TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.10.2/terraform_0.10.2_darwin_amd64.zip"
endif
TERRAFORM_LOCATION:=/usr/local/bin/terraform

define create
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform apply -var 'environment=$(1)' $(2);
endef

define graph
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform graph -draw-cycles -type plan $(2) | dot -Tpng > $(1).png;
endef

define destroy
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform destroy -var 'environment=$1' $(2);
endef

define plan
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform plan -var 'environment=$(1)' $(2);
endef

unencrypt:
	@openssl aes-256-cbc -a -md md5 -in server/key/openchs-infra.pem.enc -d -out server/key/openchs-infra.pem -k ${ENCRYPTION_KEY_AWS}

install:
	rm -rf terraform terraform.zip
	curl -L $(TERRAFORM_URL) > terraform.zip
	unzip terraform.zip
	rm -rf terraform.zip
	-sudo mv terraform $(TERRAFORM_LOCATION)
	make unencrypt

staging-create:
	$(call create,staging,server)

staging-plan:
	$(call plan,staging,server)

staging-graph:
	$(call graph,staging,server)

demo-create:
	$(call create,demo,server)

demo-plan:
	$(call plan,demo,server)

demo-graph:
	$(call graph,demo,server)

reporting-create:
	$(call create,reporting,reporting)

reporting-plan:
	$(call plan,reporting,reporting)

reporting-graph:
	$(call graph,reporting,reporting)

elk-create:
	$(call create,elk,elk)

elk-plan:
	$(call plan,elk,elk)

elk-graph:
	$(call graph,elk,elk)

elk-destroy:
	$(call destroy,elk,elk)