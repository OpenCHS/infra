.PHONY: install
UNAME := $(shell uname)
ifeq ($(UNAME),Linux)
	TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip"
endif
ifeq ($(UNAME),Darwin)
	TERRAFORM_URL="https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_darwin_amd64.zip"
endif
TERRAFORM_LOCATION:=/usr/local/bin/terraform

define create
    rm -rf server/*_override.tf
    cp -f ./server-override/$(1)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform apply -auto-approve -var 'environment=$(if $(3),$(3),$(1))' -var-file='vars/$(1).tfvars' $(2);
endef

define graph
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform graph -draw-cycles -type plan $(2) | dot -Tpng > $(1).png;
endef

define plan
    rm -rf server/*_override.tf
    cp -f ./server-override/$(1)_override.tf ./server || :
	terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform plan -var 'environment=$(if $(3),$(3),$(1))' -var-file='vars/$(1).tfvars' $(2);
endef

define create_staging_from_prod
    rm -rf server/*_override.tf
    cp -f ./server-override/from_$(2)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(3)/backend.config' $(3)
	terraform workspace select $(2) $(3) || (terraform workspace new $(2) $(3))
	terraform apply -auto-approve -var 'environment=$(2)' -var 'fromDB=$(1)' $(3);
endef

define create_prerelease_from_prod
    rm -rf server/*_override.tf
    cp -f ./server-override/from_$(2)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(3)/backend.config' $(3)
	terraform workspace select $(2) $(3) || (terraform workspace new $(2) $(3))
	terraform apply -auto-approve -var 'environment=$(2)' -var-file='vars/$(2).tfvars' -var 'fromDB=$(1)' $(3);
endef

define plan_prerelease_from_prod
    rm -rf server/*_override.tf
    cp -f ./server-override/from_$(2)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(3)/backend.config' $(3)
	terraform workspace select $(2) $(3) || (terraform workspace new $(2) $(3))
	terraform plan -var 'environment=$(2)' -var-file='vars/$(2).tfvars' -var 'fromDB=$(1)' $(3);
endef

plan-prerelease-from-prod:
	$(call plan_prerelease_from_prod,prod,prerelease,server)

create-prerelease-from-prod:
	$(call create_prerelease_from_prod,prod,prerelease,server)

define destroy
    rm -rf server/*_override.tf
    cp -f ./server-override/$(1)_override.tf ./server || :
    terraform init -backend=true -backend-config='$(2)/backend.config' $(2)
	terraform workspace select $(1) $(2) || (terraform workspace new $(1) $(2))
	terraform destroy -var 'environment=$(if $(3),$(3),$(1))' $(2);
endef

poolId=
port:= $(if $(port),$(port),8021)
server:= $(if $(server),$(server),http://localhost)
server_url:=$(server):$(port)

auth:
	$(if $(poolId),$(eval token:=$(shell node user-management/token.js $(poolId) $(clientId) $(username) $(password))))

unencrypt:
	-@openssl aes-256-cbc -a -md md5 -in server/key/openchs-infra.pem.enc -d -out server/key/openchs-infra.pem -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -md md5 -in vars/prod.tfvars.enc -d -out vars/prod.tfvars -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -md md5 -in vars/staging.tfvars.enc -d -out vars/staging.tfvars -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -md md5 -in vars/reporting.tfvars.enc -d -out vars/reporting.tfvars -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -md md5 -in vars/prerelease.tfvars.enc -d -out vars/prerelease.tfvars -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -md md5 -in vars/uat.tfvars.enc -d -out vars/uat.tfvars -k ${ENCRYPTION_KEY_AWS}

encrypt:
	-@openssl aes-256-cbc -a -in server/key/openchs-infra.pem -out server/key/openchs-infra.pem.enc -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -in vars/prod.tfvars -out vars/prod.tfvars.enc -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -in vars/staging.tfvars -out vars/staging.tfvars.enc -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -in vars/reporting.tfvars -out vars/reporting.tfvars.enc -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -in vars/uat.tfvars -out vars/uat.tfvars.enc -k ${ENCRYPTION_KEY_AWS}
	-@openssl aes-256-cbc -a -in vars/prerelease.tfvars -out vars/prerelease.tfvars.enc -k ${ENCRYPTION_KEY_AWS}

install:
	rm -rf terraform terraform.zip
	curl -L $(TERRAFORM_URL) > terraform.zip
	unzip terraform.zip
	rm -rf terraform.zip
	-sudo mv terraform $(TERRAFORM_LOCATION)
	make unencrypt

staging-create:
	$(call create,staging,server)

staging-app-create:
	$(call create,app.staging,client)

staging-webapp-create:
	$(call create,webapp.staging,webapp,staging)

staging-destroy:
	$(call destroy,staging,server)

prerelease-destroy:
	$(call destroy,prerelease,server)

staging-webapp-destroy:
	$(call destroy,webapp.staging,webapp,staging)

staging-plan:
	$(call plan,staging,server)

staging-app-plan:
	$(call plan,app.staging,client)

staging-webapp-plan:
	$(call plan,webapp.staging,webapp,staging)

production-plan:
	$(call plan,prod,server)

production-create:
	$(call create,prod,server)

staging-graph:
	$(call graph,staging,server)

demo-create:
	$(call create,demo,server)

demo-plan:
	$(call plan,demo,server)

demo-graph:
	$(call graph,demo,server)

demo-destroy:
	$(call destroy,demo,server)

uat-create:
	$(call create,uat,server)

uat-plan:
	$(call plan,uat,server)

uat-graph:
	$(call graph,uat,server)

uat-destroy:
	$(call destroy,uat,server)

reporting-create:
	$(call create,reporting,reporting)

reporting-plan:
	$(call plan,reporting,reporting)

reporting-graph:
	$(call graph,reporting,reporting)

staging-create-from-prod: staging-destroy
	$(call create_staging_from_prod,uat,staging,server)

# Generate the AUTH_HASH using basic authentication in Postman using generate code for cUrl (using your bintray user and password)
# Number range in start and end
delete-bintray-version:
	number=$(start) ; while [[ $$number -le $(end) ]] ; do \
		curl -X DELETE \
              https://api.bintray.com/packages/openchs/rpm/OpenCHS/versions/$$number \
              -H 'Authorization: Basic $(AUTH_HASH)' \
              -H 'Cache-Control: no-cache' \
              -H 'Postman-Token: 6b0484b6-eda4-4151-9aab-c33ef114994e' ; \
		((number = number + 1)) ; \
	done

# AWS Environment variables are set which will authenticate you
# Multiple profiles need to be setup like the following,
# if you want to access pools from different aws accounts
# see sample profile setup. https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html

# default profile is 'default'
awsprofile=
create-cognito-users:
	cd user-management && python create_users.py $(poolId) $(awsprofile)

create-openchs-users:
	node user-management/mapUsersToServerContract.js > temp/openchs-users.json
	curl -X POST $(server_url)/users -d @temp/openchs-users.json -H "Content-Type: application/json" -H "AUTH-TOKEN: $(token)"

create-staging-users:
	make auth create-openchs-users server=https://staging.openchs.org port=443 poolId=$(poolId) clientId=$(clientId) username=$(username) password=$(password)

create-uat-users:
	make auth create-openchs-users server=https://uat.openchs.org port=443 poolId=$(poolId) clientId=$(clientId) username=$(username) password=$(password)

create-prod-users:
	make auth create-openchs-users server=https://server.openchs.org port=443 poolId=$(poolId) clientId=$(clientId) username=$(username) password=$(password)

# MIGRATION COGNITO USERS
get-staging-users:
	aws cognito-idp list-users --user-pool-id $(STAGING_USER_POOL_ID) > cognito-users.json

migrate-users:
	aws cognito-idp list-users --user-pool-id $(poolId) > cognito-users.json
	node user-management/mapUsers.js > cognito-users-mapped.json
	curl -X POST http://localhost:8021/users -d @cognito-users-mapped.json -H "Content-Type: application/json" -H "AUTH-TOKEN: $(token)"

add-user-attribute:
#	aws cognito-idp add-custom-attributes --user-pool-id $(poolId) --custom-attributes Name=userUUID,AttributeDataType=String,Mutable=true
#	aws cognito-idp admin-update-user-attributes --username test --user-pool-id $(poolId) --user-attributes Name=custom:userUUID,Value=e011d56f-19dd-41ff-9eeb-521b37affa74
	aws cognito-idp admin-update-user-attributes --username admin --user-pool-id $(poolId) --user-attributes Name=custom:userUUID,Value=5fed2907-df3a-4867-aef5-c87f4c78a31a
	aws cognito-idp admin-update-user-attributes --username ck-demo --user-pool-id $(poolId) --user-attributes Name=custom:userUUID,Value=d36cb738-c9a7-462e-9f12-1021ed4d1065

delete-user-attributes:
	aws cognito-idp admin-delete-user-attributes --user-pool-id $(poolId) --username $(user) --user-attribute-names "custom:organisationId" "custom:isAdmin" "custom:organisationName" "custom:isOrganisationAdmin" "custom:isUser" "custom:catchmentId"

deps:
	npm i

#	One time: npm install -g cognito-backup
backup-prod-cognito:
	cognito-backup backup-users $(OPENCHS_PROD_USER_POOL_ID) --region ap-south-1 --file prod-user-pool.json
