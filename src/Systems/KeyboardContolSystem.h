#ifndef KEYBOARDCONTROLSYSTEM_H
#define KEYBOARDCONTROLSYSTEM_H

#include "ECS/ECS.h"
#include "EventBus/EventBus.h"
#include "Events/KeyPressedEvent.h"

class KeyBoardControlSystem : public System {
public:
  KeyBoardControlSystem() {}

  void SubscribeToEvents(std::unique_ptr<EventBus> &eventBus) {
    eventBus->SubscribeToEvent<KeyPressedEvent>(
        this, &KeyBoardControlSystem::OnKeyPressed);
  }

  void OnKeyPressed(KeyPressedEvent &event) {
    std::string keyCode = std::to_string(event.symbol);
    std::string keySymbol(1, event.symbol);
    Logger::Log("The KeyBoardControlSystem received a key pressed event: [" +
                keyCode + "] " + keySymbol);
  }

  void Update() {
    // TODO:...
  }
};

#endif
