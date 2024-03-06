.PHONY: build clean zip

GOOS=linux
GOARCH=amd64
BUILD_DIR=./modules/lambda/build
FUNCTIONS_DIR=./modules/lambda/functions

FUNCTIONS=$(notdir $(wildcard $(FUNCTIONS_DIR)/*))

build: $(FUNCTIONS)

$(FUNCTIONS):
	@echo "Compilando o código para $@ $(GOOS)/$(GOARCH)"
	cd $(FUNCTIONS_DIR)/$@ && GOOS=$(GOOS) GOARCH=$(GOARCH) go mod tidy
	cd $(FUNCTIONS_DIR)/$@ && GOOS=$(GOOS) GOARCH=$(GOARCH) go build -tags lambda.norpc -o ../../../../$(BUILD_DIR)/$@/bootstrap .
	@echo "Compilação de $@ concluída"

zip: clean build
	@echo "Empacotando as funções Lambda"
	@mkdir -p $(BUILD_DIR)
	@$(foreach function,$(FUNCTIONS),zip -j $(BUILD_DIR)/$(function).zip $(BUILD_DIR)/$(function)/bootstrap;)
	@echo "Arquivos ZIP criados"

clean:
	@echo "Limpando..."
	rm -rf $(BUILD_DIR)