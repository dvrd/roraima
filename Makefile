PROJ=game_engine
CC=clang++
DEPENDENCIES=sdl2, sdl2_image, sdl2_ttf, sdl2_mixer, lua
WARNNINGS=-Wall -Wextra
C_VERSION=-std=c++17
SRC_DIR=src
OUT_DIR=target/debug
INCLUDE_LIBS=-I"./libs"

IGNORE_ERRORS=2> /dev/null || true

run: main
	@echo "INFO: executing '$(PROJ)'\n"
	@$(OUT_DIR)/$(PROJ)

main:
	@make build

clear:
	@echo "INFO: removing '$(OUT_DIR)'..."
	@rm -r $(OUT_DIR) $(IGNORE_ERRORS)

build: $(OUT_DIR)
	@echo "INFO: building..."
	@$(CC) $(SRC_DIR)/*.cpp $(WARNNINGS) $(C_VERSION) -o $(OUT_DIR)/$(PROJ) $(INCLUDE_LIBS) `pkg-config --libs --cflags $(DEPENDENCIES)`

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)
