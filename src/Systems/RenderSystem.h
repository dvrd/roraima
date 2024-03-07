#ifndef RENDERSYSTEM_H
#define RENDERSYSTEM_H

#include <AssetStore/AssetStore.h>
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

  void Update(SDL_Renderer *renderer, std::unique_ptr<AssetStore> &assetStore) {
    for (auto entity : GetSystemEntities()) {
      const auto transform = entity.GetComponent<TransformComponent>();
      const auto sprite = entity.GetComponent<SpriteComponent>();

      SDL_Rect dstRect = {static_cast<int>(transform.position.x),
                          static_cast<int>(transform.position.y),
                          static_cast<int>(sprite.width * transform.scale.x),
                          static_cast<int>(sprite.height * transform.scale.y)};

      SDL_RenderCopyEx(renderer, assetStore->GetTexture(sprite.assetId),
                       &sprite.srdRect, &dstRect, transform.rotation, NULL,
                       SDL_FLIP_NONE);

      Logger::Log(
          "Entity moved to [x = " + std::to_string(transform.position.x) +
          ", y = " + std::to_string(transform.position.y) + "]");
    }
  }
};

#endif
