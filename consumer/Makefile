.PHONY: build clean zip

GOOS=linux
GOARCH=amd64
BUILD_DIR=./bin

build: 
	@echo "Compiling the code for consumer $(GOOS)/$(GOARCH)"
	GOOS=$(GOOS) GOARCH=$(GOARCH) go mod tidy
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BUILD_DIR)/main cmd/main.go
	@echo "Compilation of consumer concluded"
# strip $(BUILD_DIR)/main -o $(BUILD_DIR)/main_stripped TODO: Make it work in docker build
	@echo "Compilation of consumer concluded"

clean:
	@echo "Limpando..."
	rm -rf $(BUILD_DIR)