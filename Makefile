PROJ=roraima
CC=clang++
DEPENDENCIES=sdl2, sdl2_image, sdl2_ttf, sdl2_mixer, lua, spdlog
WARNNINGS=-Wall -Wextra -Wfatal-errors
C_VERSION=-std=c++17
SRC_FILES=src/*.cpp \
		  src/Game/*.cpp \
		  src/Logger/*.cpp \
		  src/ECS/*.cpp \
		  src/AssetStore/*.cpp \

OUT_DIR=target/debug
INCLUDE_PATH=-Ilibs -Isrc
LINKER_FLAGS = `pkg-config --libs --cflags $(DEPENDENCIES)`

IGNORE_ERRORS=2> /dev/null || true

run: main
	@echo "INFO: executing '$(PROJ)'"
	@$(OUT_DIR)/$(PROJ)

main:
	@make build

clear:
	@echo "INFO: removing '$(OUT_DIR)'..."
	@rm -r $(OUT_DIR) $(IGNORE_ERRORS)

build: $(OUT_DIR)
	@echo "INFO: building..."
	@$(CC) $(SRC_FILES) $(WARNNINGS) $(C_VERSION) -o $(OUT_DIR)/$(PROJ) $(INCLUDE_PATH) $(LINKER_FLAGS)

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)
