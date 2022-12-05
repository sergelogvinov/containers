#

TAG ?= latest
REGISTRY ?= ghcr.io/sergelogvinov
REGCACHE ?= ${REGISTRY}
PLATFORM ?= linux/arm64,linux/amd64
PUSH ?= false

BUILD_ARGS := --platform=$(PLATFORM)
ifeq ($(PUSH),true)
BUILD_ARGS += --push=$(PUSH)
else
BUILD_ARGS += --output type=cacheonly
endif

PACKAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))
PKGCACHE = $(shell echo "--cache-to type=registry,ref=$(REGCACHE)/cache:main-$1,mode=max --cache-from type=registry,ref=$(REGCACHE)/cache:main-$1")
PKGVERSION = $(shell cat $1/VERSION 2>/dev/null || echo $(TAG))

################################################################################

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Buildx activate
	docker context create multiarch ||:
	docker buildx create --name multiarch --driver docker-container --use ||:
	docker context use multiarch
	docker buildx inspect --bootstrap multiarch

list: ## List all packages
	@echo list=$(PACKAGES)

packages: $(foreach pkg,$(PACKAGES),package-$(pkg)) ## Build all packages
package-%:
	@docker buildx build $(BUILD_ARGS) $(call PKGCACHE,$*) --build-arg APPVERSION=$(call PKGVERSION,$*) \
		-t $(REGISTRY)/$*:$(call PKGVERSION,$*) -f $(word 1,$(subst :, ,$*))/Dockerfile $(word 1,$(subst :, ,$*))/

scan: $(foreach pkg,$(PACKAGES),scan-$(pkg)) ## Vulnerability scan images
scan-%:
	@trivy image --platform=$(PLATFORM) $(REGISTRY)/$*:$(call PKGVERSION,$*)
