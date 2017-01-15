# Project variables
export PROJECT_NAME ?= intake-accelerator-aws

# AWS security settings
AWS_ROLE ?= arn:aws:iam::429614120872:role/remoteAdmin

# Packer settings
export AWS_DEFAULT_REGION ?= us-west-2

# Common settings
include Makefile.settings

.PHONY: deploy/% clean

# Builds Ansible deployment environment
build:
	@ ${INFO} "Refreshing ansible roles..."
	@ ansible-galaxy install -r roles/requirements.yml --force
	@ ${INFO} "Creating ansible image..."
	@ docker-compose $(DEPLOY_ARGS) build $(PULL_FLAG) generate deploy

# Executes deployment
deploy/%: build
	@ $(if $(or $(AWS_PROFILE),$(AWS_DEFAULT_PROFILE)),$(call assume_role,$(AWS_ROLE)),)
	@ ${INFO} "Deploying to $*..."
	@ docker-compose $(DEPLOY_ARGS) run deploy ansible-playbook site.yml -e env=$*
	@ ${INFO} "Deployment complete"

# Generates templates
generate/%: export ENVIRONMENT=$*
generate/%:
	@ $(if $(or $(AWS_PROFILE),$(AWS_DEFAULT_PROFILE)),$(call assume_role,$(AWS_ROLE)),)
	@ ${INFO} "Generating $(ENVIRONMENT) deployment artifacts..."
	@ docker-compose $(DEPLOY_ARGS) up generate
	@ ${INFO} "Generation complete"

# Cleans environment
clean: 
	${INFO} "Destroying release environment..."
	@ docker-compose $(DEPLOY_ARGS) down -v || true
	${INFO} "Removing dangling images..."
	@ $(call clean_dangling_images,$(PROJECT_NAME))
	${INFO} "Clean complete"