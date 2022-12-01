#

TAG ?= latest
REGISTRY ?= ghcr.io/sergelogvinov
PLATFORM ?= linux/arm64,linux/amd64
PUSH ?= false

BUILD_ARGS :=
BUILD_ARGS += --platform=$(PLATFORM)
BUILD_ARGS += --push=$(PUSH)

PACKAGES ?= $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))

################################################################################

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

packages: $(foreach pkg,$(PACKAGES),package-$(pkg)) ## build packages

package-%:
	@docker buildx build $(BUILD_ARGS) -t $(REGISTRY)/$*:$(TAG) -f $(word 1,$(subst :, ,$*))/Dockerfile $(word 1,$(subst :, ,$*))/
