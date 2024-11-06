SHELL:=/bin/bash
# Define the path to the backend configuration file based on the current directory and ENV
TERRAFORM_BACKEND_FILE_PATH:=$(CURDIR)/config_env/$(ENV)/backend.tfvars
TERRAFORM_BIN:=terraform

# Run Terraform init.
terraform/init:
ifndef ENV
	@echo "ENV not defined, try :"
	@echo "make ENV=dev"
	@echo
	@exit 1
endif
	$(TERRAFORM_BIN) init -input=false -upgrade -backend-config=$(TERRAFORM_BACKEND_FILE_PATH)
# Run Terraform validate
terraform/validate: terraform/configure
	$(TERRAFORM_BIN) validate $(CURDIR)

terraform/configure:
 # Check if ENV variable is defined
ifndef ENV
	@echo "ENV not defined, try :"
	@echo "make ENV=dev"
	@echo
	@exit 1
endif
# Check if Terraform state file exists
ifeq (,$(wildcard $(CURDIR)/config_env/$(ENV)/config.yaml))
	@echo "Invalid environment $(ENV)"
	@echo
	@exit 1
endif
ifeq (,$(wildcard $(CURDIR)/.terraform/terraform.tfstate))
	@echo "Initialization required. Please run :"
	@echo "make ENV=$(ENV) terraform/init"
	@echo "$(CURDIR)"
	@exit 1
endif
# Create or select Terraform workspace for ENV
	$(TERRAFORM_BIN) workspace list | grep $(ENV) >/dev/null || $(TERRAFORM_BIN) workspace new $(ENV)
	$(TERRAFORM_BIN) workspace show | grep $(ENV) >/dev/null || $(TERRAFORM_BIN) workspace select $(ENV)

terraform/%: terraform/configure
	$(TERRAFORM_BIN) $(notdir $@) -input=false $(TF_CMD_ARGS)
