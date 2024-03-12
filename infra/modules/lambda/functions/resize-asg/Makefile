.PHONY: build clean zip

GOOS=linux
GOARCH=amd64
BUILD_DIR=./bin

build: 
	@echo "Compiling the code for resize ASG $(GOOS)/$(GOARCH)"
	GOOS=$(GOOS) GOARCH=$(GOARCH) go mod tidy
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -tags lambda.norpc -o $(BUILD_DIR)/bootstrap cmd/lambda/main.go
# @echo "Stripping the binary"
# cd $(BUILD_DIR) && strip bootstrap -o bootstrap_stripped
# @echo "Binary stripped"
	@echo "Compilation of resize ASG concluded"

build-local:
	@echo "Compiling the code for resize ASG"
	go mod tidy
	go build -o $(BUILD_DIR)/local cmd/lambda/main.go
	strip $(BUILD_DIR)/local -o $(BUILD_DIR)/local_stripped
	@echo "Compilation of resize ASG concluded"

zip: clean build
	@echo "Zipping Lambda functions"
	@mkdir -p $(BUILD_DIR)
	@zip -j $(BUILD_DIR)/resize-asg.zip $(BUILD_DIR)/bootstrap
	@echo "ZIP files created"

clean:
	@echo "Limpando..."
	rm -rf $(BUILD_DIR)