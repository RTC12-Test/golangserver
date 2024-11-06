# Set default shell to bash
SHELL:=/bin/bash
terraform/%:
# If ENV variable is not defined, it throws the error "ENV=dev terraform/%"
ifndef ENV
	@echo "ENV not defined, try :"
	@echo "make ENV=dev"
	@echo
	@exit 1
endif
# Recursively call makefile in the terraform directory with the specified ENV
	@make ENV=$(ENV) -C $(CURDIR)/infra/terraform $@
