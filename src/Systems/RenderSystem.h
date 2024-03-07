#ifndef RENDERSYSTEM_H
#define RENDERSYSTEM_H

#include <Components/SpriteComponent.h>
#include <Components/TransformComponent.h>
#include <ECS/ECS.h>
#include <SDL2/SDL.h>
#include <glm/glm.hpp>

class RenderSystem : public System {
public:
  RenderSystem() {
    RequireComponent<TransformComponent>();
    RequireComponent<SpriteComponent>();
  }

  void Update(SDL_Renderer *renderer) {
    for (auto entity : GetSystemEntities()) {
      const auto transform = entity.GetComponent<TransformComponent>();
      const auto sprite = entity.GetComponent<SpriteComponent>();

      SDL_Rect objRect = {static_cast<int>(transform.position.x),
                          static_cast<int>(transform.position.y), sprite.width,
                          sprite.height};
      SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
      SDL_RenderFillRect(renderer, &objRect);

      Logger::Log(
          "Entity moved to [x = " + std::to_string(transform.position.x) +
          ", y = " + std::to_string(transform.position.y) + "]");
    }
  }
};

#endif
