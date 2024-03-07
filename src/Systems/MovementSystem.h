#ifndef MOVEMNTSYSTEM_H
#define MOVEMNTSYSTEM_H

#include <Components/RigidBodyComponent.h>
#include <Components/TransformComponent.h>
#include <ECS/ECS.h>
#include <glm/glm.hpp>

class MovementSystem : public System {
public:
  MovementSystem() {
    RequireComponent<TransformComponent>();
    RequireComponent<RigidBodyComponent>();
  }

  void Update(double deltaTime) {
    for (auto entity : GetSystemEntities()) {
      auto &transform = entity.GetComponent<TransformComponent>();
      const auto rigidbody = entity.GetComponent<RigidBodyComponent>();

      transform.position.x += rigidbody.velocity.x * deltaTime;
      transform.position.y += rigidbody.velocity.y * deltaTime;

      Logger::Log(
          "Entity moved to [x = " + std::to_string(transform.position.x) +
          ", y = " + std::to_string(transform.position.y) + "]");
    }
  }
};

#endif
