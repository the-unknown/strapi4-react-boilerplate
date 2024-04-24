#!/usr/bin/make

##
## Config
##

# import config
-include .env
-include ./docker/.env
-include .env.local
export

##
## Help
##

.PHONY: help
.PHONY: list
no_targets__:
list help:
	grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS="([a-z|:]) ## "} {printf "\033[36m%-50s\033[0m %s\n", $$1, $$2}'
.DEFAULT_GOAL := help

##
## OS detection
##

ifeq ($(OS),Windows_NT)
	OS=WIN
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OS=LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OS=MAC
	endif
endif

##
## Parameter
##

export UID=$(id -u)
export GID=$(id -g)

# All general containers to be used.
#COMPOSE_FILES = -f docker/docker-compose.yml
COMPOSE_FILES = $(CFILES)

# Shortcuts. 
DC=docker compose --env-file .env 
## 
## Alias to start the project ## 

new:
	/bin/bash setup/docker/setup.sh

init: ## Initialize the project. 	
	make init-project

foo:
	echo $(TEST_CASE)
##
## DOCKER TASKS
##

up: ## Create project `recreate and run all services`.
	@${DC} ${COMPOSE_FILES} up -d --force-recreate --remove-orphans

down: ## Remove project `remove all services`.
	${DC} ${COMPOSE_FILES} down --remove-orphans -v

start: ## Start project `start services in daemon mode`.
	${DC} ${COMPOSE_FILES} up -d

stop: ## Stop project `Stop all services`.
	${DC} ${COMPOSE_FILES} stop

rm: ## Remove specific service use `make rm s=SERVICE_NAME`.
	${DC} ${COMPOSE_FILES} rm -f -s -v ${s}

pull:
	${DC} ${COMPOSE_FILES} pull

build: pull ## Build application images (pull images).
	${DC} ${COMPOSE_FILES} build --parallel

##
## Docker Stats
##

image-size: ## Show service images.
	${DC} ${COMPOSE_FILES} images

ps: ## Show running containers.
	${DC} ${COMPOSE_FILES} ps

stats: ## Show service statistics.
	docker stats

top: ## Show service processes.
	${DC} ${COMPOSE_FILES} top

##
## DOCKER CLEAN UP
##

reset-project: ## !!WARNING!! Remove everything, clear docker and re-init the project.
	rm git-clean clear-container clear-images clear-volumes clear-networks init

git-clean-dry: ## !!WARNING!! Show which files that are untracked would be deleted.
	git clean -dfXn

git-clean: ## !!WARNING!! Clear all untracked files (gitignored).
	git clean -dfX

clear-container: ## !!WARNING!! remove all containers.
	docker rm -f $$(docker ps -a -q)

clear-images: ## !!WARNING!! Remove all images.
	docker rmi -f $$(docker images -a -q)

clear-images-soft: ## !!WARNING!! Force delete all images from the last 24 hours.
	docker images | grep -E "(minutes|hours) ago" | awk '{print $3}' | xargs docker image rm -f

clear-volumes: ## !!WARNING!!  Remove all volumes.
	docker volume rm $$(docker volume ls -q)

clear-networks: # !!WARNING!! Remove all networks.
	docker network rm $$(docker network ls | tail -n+2 | awk '{if($2 !~ /bridge|none|host/){ print $1 }}')

##
## Utility commands
##

logs: ## Show service logs `make logs c=SERVICE_NAME`
	${DC} ${COMPOSE_FILES} logs --tail="all" -f ${c}

cli: ## Run service command `make cli c=SERVICE_NAME command="COMMAND_NAME"`
	${DC} ${COMPOSE_FILES} exec ${c} /bin/sh -c "${command}"

inspect: ## Get service configuration `make inspect c=SERVICE_NAME`
	docker inspect $$(${DC} ${COMPOSE_FILES} ps -q ${c})

exec ssh: ## Jump into the shell of a container `make exec c=SERVICE_NAME` or `make ssh c=SERVICE_NAME`
	${DC} ${COMPOSE_FILES} exec ${c} /bin/sh

##
## CERTIFICATE
##
install-cert-linux:
	sudo cp setup/ssl/showroom.local.crt /usr/local/share/ca-certificates/showroom.local.crt
	sudo update-ca-certificates
	sudo apt install libnss3-tools
	/bin/bash setup/local-cert-install-linux.sh

remove-cert-linux:
	sudo rm /usr/local/share/ca-certificates/showroom.local.crt
	sudo update-ca-certificates --fresh
	/bin/bash setup/local-cert-remove-linux.sh	
	
##
## init this project initially once
##

init-project: # -k == --keep-going
	make rm up ui-init -k

update:
	make stop && sudo chown $(USER):$(USER) apps/ -R && git pull origin main && make cms-restore up

include Makefile.ui
