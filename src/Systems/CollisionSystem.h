#ifndef COLLISIONSYSTEM_H
#define COLLISIONSYSTEM_H

#include <Components/BoxColliderComponent.h>
#include <Components/TransformComponent.h>
#include <ECS/ECS.h>
#include <SDL2/SDL.h>

class CollisionSystem : public System {
public:
  CollisionSystem() {
    RequireComponent<BoxColliderComponent>();
    RequireComponent<TransformComponent>();
  }

  void Update() {
    auto entities = GetSystemEntities();

    for (auto i = entities.begin(); i != entities.end(); i++) {
      Entity &a = *i;
      auto &aTransform = a.GetComponent<TransformComponent>();
      auto &aCollider = a.GetComponent<BoxColliderComponent>();

      for (auto j = i; j != entities.end(); j++) {
        Entity &b = *j;

        if (a == b) {
          continue;
        }

        auto &bTransform = b.GetComponent<TransformComponent>();
        auto &bCollider = b.GetComponent<BoxColliderComponent>();

        bool collisionHappened = CheckAABBCollision(
            aTransform.position.x, aTransform.position.y, aCollider.width,
            aCollider.height, bTransform.position.x, bTransform.position.y,
            bCollider.width, bCollider.height);

        if (collisionHappened) {
          Logger::Log("Entity " + std::to_string(a.GetId()) +
                      " is colliding with entity " + std::to_string(b.GetId()));
          a.Kill();
          b.Kill();
        }
      }
    }
  }

  bool CheckAABBCollision(double aX, double aY, double aW, double aH, double bX,
                          double bY, double bW, double bH) {
    return (aX < bY + bW && aX + aW > bX && aY < bY + bH && aY + aH > bY);
  }
};

#endif
