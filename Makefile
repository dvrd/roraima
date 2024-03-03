PROJ=roraima
SRC_DIR=src
DEBUG_OUT_DIR=target/debug
RELEASE_OUT_DIR=target/debug

IGNORE_ERRORS=2> /dev/null || true

run: main
	@echo "INFO: executing '$(PROJ)'\n"
	@$(DEBUG_OUT_DIR)/$(PROJ)

debug: main
	@echo "INFO: initializing debugger"
	@lldb $(OUT_DIR)/$(PROJ)

main:
	@odin build $(SRC_DIR) -out:$(DEBUG_OUT_DIR)/$(PROJ) -debug

clear:
	@echo "INFO: removing binaries..."
	@rm -rf target $(IGNORE_ERRORS)

build: $(OUT_DIR)
	@echo "INFO: building..."
	@odin build $(SRC_DIR) -out:$(RELEASE_OUT_DIR)/$(PROJ) -o:speed

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)
