PROJ=roraima
SRC_DIR=src
DEBUG_OUT_DIR=target/debug
RELEASE_OUT_DIR=target/release
COLLECTIONS=-collection:roraima=src

IGNORE_ERRORS=2> /dev/null || true

run: build_debug
	@echo "BUILD_INFO: executing '$(PROJ)'\n"
	@$(DEBUG_OUT_DIR)/$(PROJ)

debug: build_debug
	@echo "BUILD_INFO: initializing debugger"
	@lldb $(DEBUG_OUT_DIR)/$(PROJ)

release: build
	@echo "BUILD_INFO: executing release version of '$(PROJ)'"
	@$(RELEASE_OUT_DIR)/$(PROJ)

clear:
	@echo "BUILD_INFO: removing all binaries..."
	@rm -rf target $(IGNORE_ERRORS)

build_debug: $(DEBUG_OUT_DIR)
	@echo "BUILD_INFO: building debug version..."
	@odin build $(SRC_DIR) -out:$(DEBUG_OUT_DIR)/$(PROJ) -debug $(COLECTIONS)

build: $(RELEASE_OUT_DIR)
	@echo "BUILD_INFO: building release version..."
	@odin build $(SRC_DIR) -out:$(RELEASE_OUT_DIR)/$(PROJ) -o:speed $(COLECTIONS)

$(DEBUG_OUT_DIR):
	@mkdir -p $(DEBUG_OUT_DIR)

$(RELEASE_OUT_DIR):
	@mkdir -p $(RELEASE_OUT_DIR)
