PROJ=roraima
SRC_DIR=src
DEBUG_OUT_DIR=target/debug
RELEASE_OUT_DIR=target/release

IGNORE_ERRORS=2> /dev/null || true

run: build_debug
	@echo "INFO: executing '$(PROJ)'\n"
	@$(DEBUG_OUT_DIR)/$(PROJ)

debug: build_debug
	@echo "INFO: initializing debugger"
	@lldb $(DEBUG_OUT_DIR)/$(PROJ)

clear:
	@echo "INFO: removing binaries..."
	@rm -rf target $(IGNORE_ERRORS)

build_debug: $(DEBUG_OUT_DIR)
	@echo "INFO: building..."
	@odin build $(SRC_DIR) -out:$(DEBUG_OUT_DIR)/$(PROJ) -debug

build: $(RELEASE_OUT_DIR)
	@echo "INFO: building..."
	@odin build $(SRC_DIR) -out:$(RELEASE_OUT_DIR)/$(PROJ) -o:speed

$(DEBUG_OUT_DIR):
	@mkdir -p $(DEBUG_OUT_DIR)

$(RELEASE_OUT_DIR):
	@mkdir -p $(RELEASE_OUT_DIR)
