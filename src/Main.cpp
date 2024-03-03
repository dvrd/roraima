#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_mixer.h>
#include <SDL2/SDL_ttf.h>
#include <glm/glm.hpp>
#include <imgui/imgui.h>
#include <iostream>
#include <sol/sol.hpp>

int main() {
  sol::state lua;
  lua.open_libraries(sol::lib::base);

  glm::vec2 velocity = glm::vec2(5.0, -2.5);
  velocity = glm::normalize(velocity);

  SDL_Init(SDL_INIT_EVERYTHING);

  std::cout << "Yay! Dependencies work correctly" << std::endl;
  return 0;
}
