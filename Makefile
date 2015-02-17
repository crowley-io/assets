all: release

DIRECTORY=$(shell pwd)

INPUT?=$(DIRECTORY)/bin
OUTPUT?=$(DIRECTORY)/bin.go

GO_BINDATA_BIN?=$(GOPATH)/bin/go-bindata
GO_BINDATA_OPTS=-pkg assets -prefix bin/

APP_DIRECTORY=/app/src/github.com/crowley-io/assets
APP_INPUT=/usr/src/app/bin

DOCKER_VOLUME_BIND=$(DIRECTORY):$(APP_DIRECTORY)

setup: $(GO_BINDATA_BIN) $(INPUT)
	go get -d -v ./...

develop: setup
	$(GO_BINDATA_BIN) $(GO_BINDATA_OPTS) -debug -o $(OUTPUT) $(INPUT)/... 

release: setup
	$(GO_BINDATA_BIN) $(GO_BINDATA_OPTS) -o $(OUTPUT) $(INPUT)/...

style:
	gofmt -w .

test: setup
	go list -f '{{range .TestImports}}{{.}} {{end}}' ./... | xargs -n1 go get -d
	go list ./... | xargs -n1 go test

clean:
	rm $(OUTPUT)
	rm -rf $(DIRECTORY)/bin

docker:
	docker run --rm -it -v $(DOCKER_VOLUME_BIND) -w $(APP_DIRECTORY) crowleyio/develop make

docker-bash:
	docker run --rm -it -v $(DOCKER_VOLUME_BIND) -w $(APP_DIRECTORY) crowleyio/develop /bin/bash || true

$(GO_BINDATA_BIN):
	go get -u github.com/jteeuwen/go-bindata/...

$(DIRECTORY)/bin:
	tar -xvf crowley-ui.tar.gz