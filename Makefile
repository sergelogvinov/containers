#

TAG ?= latest
REGISTRY ?= ghcr.io/sergelogvinov
REGSYNC  ?= sergelog
REGCACHE ?= ${REGISTRY}
PLATFORM ?= linux/arm64,linux/amd64
PUSH ?= false

BUILD_ARGS := --platform=$(PLATFORM)
ifeq ($(PUSH),true)
BUILD_ARGS += --push=$(PUSH)
else ifeq ($(CI),true)
BUILD_ARGS += --progress=plain
else
BUILD_ARGS += --output type=docker
endif

PACKAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))
PKGCACHE = $(shell echo "--cache-to type=registry,ref=$(REGCACHE)/cache:main-$1,mode=max --cache-from type=registry,ref=$(REGCACHE)/cache:main-$1")
PKGTARGET ?= pkg
PKGVERSION = $(shell head -n 1 $1/VERSION 2>/dev/null || echo $(TAG))

################################################################################

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Buildx activate
	docker run --rm --privileged multiarch/qemu-user-static:register --reset

	docker context create multiarch ||:
	docker buildx create --name multiarch --driver docker-container --use ||:
	docker context use multiarch
	docker buildx inspect --bootstrap multiarch

list: ## List all packages
	@echo -n $(PACKAGES)

packages: $(foreach pkg,$(PACKAGES),package-$(pkg)) ## Build all packages
package-%:
	@docker buildx build $(BUILD_ARGS) $(call PKGCACHE,$*) --build-arg APPVERSION=$(call PKGVERSION,$*) \
		$(foreach tag,$(shell cat $*/VERSION 2>/dev/null || echo $(TAG)),-t $(REGISTRY)/$*:$(subst -pkg,,$(tag)-$(PKGTARGET))) \
		-f $(word 1,$(subst :, ,$*))/Dockerfile \
		--target=$(PKGTARGET) \
		$(word 1,$(subst :, ,$*))/

sync: $(foreach pkg,$(PACKAGES),sync-$(pkg)) ## Copy all packages to another repo
sync-%:
	@skopeo copy --dest-authfile=~/.docker/config.json --multi-arch=all --override-os=linux \
		docker://$(REGISTRY)/$*:$(call PKGVERSION,$*) docker://$(REGSYNC)/$*:$(call PKGVERSION,$*)

scan: $(foreach pkg,$(PACKAGES),scan-$(pkg)) ## Vulnerability scan images
scan-%:
	@trivy image --platform=$(PLATFORM) $(REGISTRY)/$*:$(call PKGVERSION,$*)
