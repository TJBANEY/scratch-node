PREFIX?=astefanutti
VERSION?=13.13.0

# This option is for running docker manifest command
export DOCKER_CLI_EXPERIMENTAL := enabled

ALL_ARCHITECTURES=amd64 arm32v6 arm32v7 arm64v8

tag-images:
	@for arch in $(ALL_ARCHITECTURES); do docker tag $(PREFIX)/scratch-node:${VERSION}-$${arch} $(PREFIX)/scratch-node:${TAG}-$${arch}; done

build-images:
	@for arch in $(ALL_ARCHITECTURES); do docker build --build-arg version=${VERSION} --build-arg arch=$${arch} -t $(PREFIX)/scratch-node:${VERSION}-$${arch} .; done

push-images:
	@for arch in $(ALL_ARCHITECTURES); do docker push $(PREFIX)/scratch-node:${VERSION}-$${arch}; done

create-manifest: push-images
	docker manifest create --amend $(PREFIX)/scratch-node:$(VERSION) $(shell echo $(ALL_ARCHITECTURES) | sed -e "s~[^ ]*~$(PREFIX)/scratch-node:$(VERSION)\-&~g")
	docker manifest annotate --os linux --arch amd64 $(PREFIX)/scratch-node:${VERSION} $(PREFIX)/scratch-node:${VERSION}-amd64
	# TODO: set the CPU features as soon as the CLI exposes a --features option
	docker manifest annotate --os linux --arch arm --variant v6 $(PREFIX)/scratch-node:${VERSION} $(PREFIX)/scratch-node:${VERSION}-arm32v6
	docker manifest annotate --os linux --arch arm --variant v7 $(PREFIX)/scratch-node:${VERSION} $(PREFIX)/scratch-node:${VERSION}-arm32v7
	docker manifest annotate --os linux --arch arm64 --variant v8 $(PREFIX)/scratch-node:${VERSION} $(PREFIX)/scratch-node:${VERSION}-arm64v8

push-manifest: create-manifest
	docker manifest push --purge $(PREFIX)/scratch-node:${VERSION}
