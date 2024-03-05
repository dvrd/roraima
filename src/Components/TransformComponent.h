#ifndef TRANSFORMCOMPOENNT_H
#define TRANSFORMCOMPOENNT_H

#include <glm/glm.hpp>

struct TransformComponent {
  glm::vec2 position;
  glm::vec2 scale;
  double rotation;
};

#endif
