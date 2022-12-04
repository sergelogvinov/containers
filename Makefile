#

TAG ?= latest
REGISTRY ?= ghcr.io/sergelogvinov
PLATFORM ?= linux/arm64,linux/amd64
PUSH ?= false

BUILD_ARGS := --platform=$(PLATFORM)
ifeq ($(PUSH),true)
BUILD_ARGS += --push=$(PUSH)
else
BUILD_ARGS += --output type=cacheonly
endif

PACKAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))
PKGCACHE = $(shell echo "--cache-to type=registry,ref=$(REGISTRY)/cache:main-$1,compression=zstd,mode=max --cache-from type=registry,ref=$(REGISTRY)/cache:main-$1")
PKGVERSION = $(shell cat $1/VERSION 2>/dev/null || echo $(TAG))

################################################################################

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

packages: $(foreach pkg,$(PACKAGES),package-$(pkg)) ## build packages

package-%:
	docker buildx build $(BUILD_ARGS) $(call PKGCACHE,$*) --build-arg APPVERSION=$(call PKGVERSION,$*) \
		-t $(REGISTRY)/$*:$(call PKGVERSION,$*) -f $(word 1,$(subst :, ,$*))/Dockerfile $(word 1,$(subst :, ,$*))/
