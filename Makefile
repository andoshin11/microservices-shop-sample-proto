PROJECT := microservices-shop-sample-proto
REPO := github.com/andoshin11/$(PROJECT)
PROTO_FILES := $(shell find proto -type f -name \*.proto | sed -e 's/^proto\///g')

BUF_VERSION := 0.19.0
# flag
BUF_INSTALL_FROM_SOURCE := false

UNAME_OS := $(shell uname -s)
UNAME_ARCH := $(shell uname -m)
# Buf will be cached to ~/.cache/microservices-shop-sample-proto.
CACHE_BASE := $(HOME)/.cache/$(PROJECT)
# This allows switching between i.e a Docker container and your local setup without overwriting.
CACHE := $(CACHE_BASE)/$(UNAME_OS)/$(UNAME_ARCH)
# The location where buf will be installed.
CACHE_BIN := $(CACHE)/bin
# Marker files are put into this directory to denote the current version of binaries that are installed.
CACHE_VERSIONS := $(CACHE)/versions

BUF := $(CACHE_VERSIONS)/buf/$(BUF_VERSION)
$(BUF):
	@rm -f $(CACHE_BIN)/buf
	@mkdir -p $(CACHE_BIN)
ifeq ($(BUF_INSTALL_FROM_SOURCE),true)
	$(eval BUF_TMP := $(shell mktemp -d))
	cd $(BUF_TMP); go get github.com/bufbuild/buf/cmd/buf@$(BUF_VERSION)
	@rm -rf $(BUF_TMP)
else
	curl -sSL \
		"https://github.com/bufbuild/buf/releases/download/v$(BUF_VERSION)/buf-$(UNAME_OS)-$(UNAME_ARCH)" \
		-o "$(CACHE_BIN)/buf"
	chmod +x "$(CACHE_BIN)/buf"
endif
	@rm -rf $(dir $(BUF))
	@mkdir -p $(dir $(BUF))
	@touch $(BUF)

.PHONY: lint
lint: $(BUF)
	buf check lint

.PHONY: gen-proto-all
gen-proto-all: gen-proto-go

.PHONY: gen-proto-go
gen-proto-go:
	buf image build -o - | protoc --descriptor_set_in=/dev/stdin --go_out=plugins=grpc:protogen $(PROTO_FILES)
