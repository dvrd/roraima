#ifndef RENDERCOLLIDERSYSTEM_H
#define RENDERCOLLIDERSYSTEM_H

#include "Components/BoxColliderComponent.h"
#include "Components/TransformComponent.h"
#include "ECS/ECS.h"
#include <SDL2/SDL.h>

class RenderColliderSystem : public System {
public:
  RenderColliderSystem() {
    RequireComponent<BoxColliderComponent>();
    RequireComponent<TransformComponent>();
  }

  void Update(SDL_Renderer *renderer) {
    auto entities = GetSystemEntities();

    for (auto entity : GetSystemEntities()) {
      const auto &transform = entity.GetComponent<TransformComponent>();
      const auto &collider = entity.GetComponent<BoxColliderComponent>();

      SDL_Rect colliderRect = {static_cast<int>(transform.position.x),
                               static_cast<int>(transform.position.y),
                               static_cast<int>(collider.width),
                               static_cast<int>(collider.height)};
      SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
      SDL_RenderDrawRect(renderer, &colliderRect);
    }
  }
};

#endif
