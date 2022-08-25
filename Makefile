PROJECT_PATH=${PWD}
TARGETPLATFORM?=linux/amd64

.PHONY: test
test:
	go test ./...

.PHONY: e2e
e2e:
	go clean -testcache
	go test ./... --tags=e2e_parallel
	go test ./... -p 1 --tags=e2e_sequential

.PHONY: tidy
tidy:
	go mod tidy

.PHONY: doc
doc:
	cd documentation/gen/; go run .

.PHONY: lint
lint:
	docker run --rm -v $(pwd):/data cytopia/yamllint .
	golangci-lint run --color always --timeout 240s

.PHONY: example
example:
	deploy/tests/create.sh

.PHONY: example-rebuild
example-rebuild:
	deploy/tests/rebuild.sh

.PHONY: example-remove
example-remove:
	deploy/tests/delete.sh

.PHONY: build
build:
	docker build -t haproxytech/kubernetes-ingress --build-arg TARGETPLATFORM=$(TARGETPLATFORM) -f build/Dockerfile .

.PHONY: publish
publish:
	goreleaser release --rm-dist

.PHONY: cr_generate
cr_generate:
	crs/code-generator.sh
	grep -lir defaultses crs/* | xargs sed -i 's/Defaultses/Defaults/g'
	grep -lir defaultses crs/* | xargs sed -i 's/defaultses/defaults/g'
