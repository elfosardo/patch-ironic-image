.PHONY: build

build:
	podman build -t container_tag --build-arg MY_IMAGE="${MY_IMAGE}" -f Dockerfile.patch

