.PHONY: build clean zip

GOOS=linux
GOARCH=amd64
BUILD_DIR=./bin

build: 
	@echo "Compiling the code for create-spot-instance $(GOOS)/$(GOARCH)"
	GOOS=$(GOOS) GOARCH=$(GOARCH) go mod tidy
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -tags lambda.norpc -o $(BUILD_DIR)/create-spot-instance/bootstrap .
	@echo "Compilation of create-spot-instance concluded"

zip: clean build
	@echo "Zipping Lambda functions"
	@mkdir -p $(BUILD_DIR)
	@zip -j $(BUILD_DIR)/create-spot-instance.zip $(BUILD_DIR)/create-spot-instance/bootstrap
	@echo "ZIP files created"

clean:
	@echo "Limpando..."
	rm -rf $(BUILD_DIR)