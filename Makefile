branch = $(shell git rev-parse --abbrev-ref HEAD)

.ONESHELL .PHONY: build
.DEFAULT_GOAL := build

custom_ca:
ifdef CUSTOM_CA
	cp -rf $(CUSTOM_CA)/* ca_certificates/ || cp -f $(CUSTOM_CA) ca_certificates/
endif

build: custom_ca
	docker build . -t local/alpine-jdk11-openssl:$(branch)
	docker tag  local/alpine-jdk11-openssl:$(branch) local/alpine-jdk11-openssl:latest

