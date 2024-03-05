#ifndef MOVEMNTSYSTEM_H
#define MOVEMNTSYSTEM_H

#include <ECS/ECS.h>
#include <glm/glm.hpp>

class MovementSystem : public System {
public:
  MovementSystem() {
    // TODO:
    // RequireComponent<TransformComponent>();
    // RequireComponent<...>();
  }

  void Update() {
    // TODO:
    // Loop all entities trat the sustem is interested in
    for (auto entity : GetEntities()) {
      // Update entity position based on its velocity
    }
  }
};

#endif
