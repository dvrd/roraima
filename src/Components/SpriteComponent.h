#ifndef SPRITECOMPONENT_H
#define SPRITECOMPONENT_H

#include <SDL2/SDL.h>
#include <glm/glm.hpp>
#include <string>

struct SpriteComponent {
  std::string assetId;
  int width;
  int height;
  SDL_Rect srdRect;

  SpriteComponent(std::string assetId = "", int width = 0, int height = 0,
                  int srdRectX = 0, int srdRectY = 0) {
    this->assetId = assetId;
    this->width = width;
    this->height = height;
    this->srdRect = {srdRectX, srdRectY, width, height};
  }
};

#endif
