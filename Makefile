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
	cd _vendor/go-fuzz/go-fuzz; go build; mv go-fuzz ../../../bin/
  
bin/go-fuzz-build: bin
	git submodule init
	git submodule update
	cd _vendor/go-fuzz/go-fuzz-build; \
	for arch in {darwin,linux,windows}; do \
	  GOOS=$$arch go build; \
	  mv go-fuzz-build ../../../bin/; \
 	done
  
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
