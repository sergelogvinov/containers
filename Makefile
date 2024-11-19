#

TAG ?= latest
REGISTRY ?= ghcr.io/sergelogvinov
REGSYNC  ?= sergelog
REGCACHE ?= ${REGISTRY}
PLATFORM ?= linux/arm64,linux/amd64
PUSH ?= false

BUILD_ARGS := --platform=$(PLATFORM)
ifeq ($(PUSH),true)
BUILD_ARGS += --push=$(PUSH) --output type=image,annotation-index.org.opencontainers.image.source="https://github.com/sergelogvinov/containers"
else ifeq ($(CI),true)
BUILD_ARGS += --progress=plain
else
BUILD_ARGS += --output type=docker
endif

COSING_ARGS ?=

ifdef ACTIONS_RUNTIME_TOKEN
PKGCACHE = $(shell echo "--cache-to type=gha,mode=max --cache-from type=gha")
else ifdef REGCACHE_UPLOAD
PKGCACHE = $(shell echo "--cache-to type=registry,ref=$(REGCACHE)/cache:main-$1,mode=max --cache-from type=registry,ref=$(REGCACHE)/cache:main-$1")
else
PKGCACHE = $(shell echo "--cache-from type=registry,ref=$(REGCACHE)/cache:main-$1")
endif

PACKAGES = $(patsubst %/,%,$(dir $(wildcard */Dockerfile)))
PKGTARGET ?= pkg
PKGVERSION = $(shell grep -v "#" $1/VERSION | head -n 1 2>/dev/null || echo $(TAG))

################################################################################

help:
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Buildx activate
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

	docker context create multiarch ||:
	docker buildx create --name multiarch --driver docker-container --use ||:
	docker context use multiarch
	docker buildx inspect --bootstrap multiarch

list: ## List all packages
	@echo -n $(PACKAGES)

################################################################################

define build
	@docker buildx build $(BUILD_ARGS) $(call PKGCACHE,$(1)) --build-arg APPVERSION=$(call PKGVERSION,$(1)) \
		$(foreach tag,$(shell grep -v "#" $(1)/VERSION 2>/dev/null || echo $(TAG)),-t $(REGISTRY)/$(1):$(subst -pkg,,$(tag)-$(2))) \
		-f $(word 1,$(subst :, ,$(1)))/Dockerfile \
		--target=$(2) \
		$(word 1,$(subst :, ,$(1)))/
endef

packages: $(foreach pkg,$(PACKAGES),package-$(pkg)) ## Build all packages

package-fluentd:
	$(call build,fluentd,pkg)
	$(call build,fluentd,clickhouse)
package-nginx-openresty:
	$(call build,nginx-openresty,pkg)
	$(call build,nginx-openresty,device-detection)
package-github-actions-runner:
	$(call build,github-actions-runner,pkg)
	$(call build,github-actions-runner,aws)
	$(call build,github-actions-runner,gcp)
package-teamcity:
	$(call build,teamcity,pkg)
	$(call build,teamcity,agent)
package-wal-g:
	$(call build,wal-g,pg)
	$(call build,wal-g,mongo)
	$(call build,wal-g,redis)

package-%:
	$(call build,$*,$(PKGTARGET))

################################################################################

define cosign
	cosign sign --yes $(COSING_ARGS) --recursive $(foreach tag,$(shell grep -v "#" $(1)/VERSION 2>/dev/null || echo $(TAG)),$(REGISTRY)/$(1):$(subst -pkg,,$(tag)-$(2)))
endef

cosign-%:
	$(call cosign,$*,$(PKGTARGET))

################################################################################

sync: $(foreach pkg,$(PACKAGES),sync-$(pkg)) ## Copy all packages to another repo
sync-%:
	@skopeo copy --dest-authfile=~/.docker/config.json --multi-arch=all --override-os=linux \
		docker://$(REGISTRY)/$*:$(call PKGVERSION,$*) docker://$(REGSYNC)/$*:$(call PKGVERSION,$*)

scan: $(foreach pkg,$(PACKAGES),scan-$(pkg)) ## Vulnerability scan images
scan-%:
	@trivy image --platform=$(PLATFORM) $(REGISTRY)/$*:$(call PKGVERSION,$*)
