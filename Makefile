# Makefile for Terraform

ifndef LOCATION
	LOCATION=.
endif

.PHONY: clean
clean: ## Erase all project. VERY DESTRUCTIVE!
	@bash ./cleanup.sh

.PHONY: init
init: ## Init terraform
	cd $(LOCATION) && \
	terraform init

.PHONY: init-proj
init-proj: ## Init S3 buckets for tfstate and configure backend
	@bash ./init.sh

.PHONY: fmt
fmt:
	cd $(LOCATION) && \
	terraform fmt

.PHONY: lint
lint: ## Lint HCL
	cd $(LOCATION) && \
	tflint

.PHONY: security
security: ## Run tfsec validation
	cd $(LOCATION) && \
	tfsec

.PHONY: validate
validate: ## Validate syntax
	cd $(LOCATION) && \
	terraform validate

.PHONY: show
show: ## Show state
	cd $(LOCATION) && \
	terraform show

.PHONY: console
console: ## Enter terraform console
	cd $(LOCATION) && \
	terraform console

.PHONY: plan
plan: dry-run

.PHONY: dry-run
dry-run: ## Prepare tfplan to update resources
	cd $(LOCATION) && \
	terraform plan

.PHONY: apply
apply: run

.PHONY: run
run: ## Apply tfplan
	cd $(LOCATION) && \
	terraform apply tfplan

.PHONY: destroy
destroy: ## Prepare tfplan to destroy resources
	cd $(LOCATION) && \
	terraform plan

help:
	@printf "\033[32mTerraform Makefile\033[0m\n\n"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
