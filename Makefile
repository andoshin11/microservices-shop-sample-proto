REPO := github.com/andoshin11/microservices-shop-sample-proto
PKG_NAME := shopsample
PROTO_FILES := $(shell find proto -type f -name \*.proto | sed -e 's/^proto\///g')

.PHONY: lint
lint:
	buf check lint

.PHONY: gen-proto-all
gen-proto-all: gen-proto-go

.PHONY: gen-proto-go
gen-proto-go:
	buf image build -o - | protoc --descriptor_set_in=/dev/stdin --go_opt=paths=source_relative --go_out=plugins=grpc:protogen $(PROTO_FILES)
