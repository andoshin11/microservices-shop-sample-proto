REPO := github.com/andoshin11/microservices-shop-sample-proto
PKG_NAME := shopsample

.PHONY: lint
lint:
	buf check lint

.PHONY: gen-proto-all
gen-proto-all: gen-proto-go

.PHONY: gen-proto-go
gen-proto-go:
	buf image build -o - | protoc --descriptor_set_in=/dev/stdin --go_out=plugins=grpc:gen $(PKG_NAME).proto
	mv gen/$(REPO)/$(PKG_NAME)/$(PKG_NAME).pb.go gen/$(PKG_NAME).pb.go
