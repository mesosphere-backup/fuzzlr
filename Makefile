default: clean bin/go-fuzz_executor bin/go-fuzz_scheduler bin/go-fuzz

run: clean bin/go-fuzz_executor bin/go-fuzz run-scheduler

clean:
	-rm bin/fuzzlr_*

bin:
	-mkdir bin

bin/fuzzlr-scheduler: bin
	go build -o bin/fuzzler-scheduler cmd/fuzzlr-scheduler/app.go

bin/fuzzlr_executor: bin
	go build -o bin/fuzzlr-executor cmd/fuzzlr-executor/app.go

bin/go-fuzz: bin
	git submodule init
	git submodule update
	cd _vendor/go-fuzz/go-fuzz; \
	for arch in {darwin,linux}; do \
	  GOOS=$$arch go build -o ../../../bin/go-fuzz-$$arch; \
	done
  
bin/go-fuzz-build: bin
	git submodule init
	git submodule update
	cd _vendor/go-fuzz/go-fuzz-build; go build -o ../../../bin/go-fuzz-build

bin/test: bin/go-fuzz-build
	for arch in {darwin,linux}; do \
	  GOOS=$$arch bin/go-fuzz-build -o bin/fmt-fuzz-$$arch.zip github.com/dvyukov/go-fuzz/examples/png; \
	done

bin/corpus.zip: bin
	zip bin/corpus.zip $(GOPATH)/src/github.com/dvyukov/go-fuzz/examples/png/corpus/*

go-fuzz: bin/go-fuzz bin/test bin/corpus.zip

run-scheduler:
	go run -race cmd/fuzzlr-scheduler/app.go -logtostderr=true

install:
	go install ./cmd/...

cover:
	for i in `dirname **/*_test.go | grep -v "_vendor" | sort | uniq`; do \
		echo $$i; \
		go test -v -race ./$$i/... -coverprofile=em-coverage.out; \
		go tool cover -func=em-coverage.out; rm em-coverage.out; \
	done

test:
	go test -race ./...
