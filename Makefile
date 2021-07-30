.PHONY: build

SHELL=/bin/bash

build:
	source config.txt; \
	podman build -t $${CONTAINER_TAG} --build-arg MY_IMAGE=$${MY_IMAGE} -f Dockerfile.patch

