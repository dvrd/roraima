
#ifndef ECS_H
#define ECS_H

#include <Logger/Logger.h>
#include <bitset>
#include <deque>
#include <set>
#include <typeindex>
#include <unordered_map>
#include <vector>

const unsigned int MAX_COMPONENTS = 32;

typedef std::bitset<MAX_COMPONENTS> Signature;

class Registry;

struct IComponent {
protected:
  static int nextId;
};

// INFO: Used to assign a unique id to a component type
template <typename T> class Component : public IComponent {
public:
  static int GetId() {
    static auto id = nextId++;
    return id;
  }
};

class Entity {
private:
  int id;

public:
  Entity(int id) : id(id){};
  Entity(const Entity &entity) = default;
  void Kill();
  int GetId() const;

  Entity &operator=(const Entity &other) = default;
  bool operator==(const Entity &other) const { return id == other.id; }
  bool operator!=(const Entity &other) const { return id != other.id; }
  bool operator>(const Entity &other) const { return id > other.id; }
  bool operator<(const Entity &other) const { return id < other.id; }
  bool operator>=(const Entity &other) const { return id >= other.id; }
  bool operator<=(const Entity &other) const { return id <= other.id; }

  template <typename TComponent, typename... TArgs>
  void AddComponent(TArgs &&...args);
  template <typename TComponent> void RemoveComponent();
  template <typename TComponent> bool HasComponent() const;
  template <typename TComponent> TComponent &GetComponent() const;

  class Registry *registry;
};

class System {
private:
  Signature componentSignature;
  std::vector<Entity> entities;

public:
  System() = default;
  ~System() = default;

  void AddEntityToSystem(Entity entity);
  void RemoveEntityFromSystem(Entity entity);
  std::vector<Entity> GetSystemEntities() const;
  const Signature &GetComponentSignature() const;

  // INFO: Defines the component type that entities must have to be considered
  // by the system
  template <typename TComponent> void RequireComponent();
};

template <typename TComponent> void System::RequireComponent() {
  const auto componentId = Component<TComponent>::GetId();
  componentSignature.set(componentId);
}

class IPool {
public:
  virtual ~IPool() {}
};

template <typename T> class Pool : public IPool {
private:
  std::vector<T> data;

public:
  Pool(int size = 100) { Resize(size); }
  virtual ~Pool() = default;

  bool IsEmpty() const { return data.empty(); }
  int GetSize() const { return data.size(); }
  void Resize(int n) { data.resize(n); }
  void Clear() { data.clear(); }
  void Add(T object) { data.push_back(object); }
  void Set(int index, T object) { data[index] = object; }
  T &Get(int index) { return static_cast<T &>(data[index]); }
  T &operator[](unsigned int index) { return data[index]; }
};

class Registry {
private:
  int numEntities = 0;

  // INFO:
  // Vector of component pools. each pool contains all the data fo r a certain
  // compoennt type
  // [Vector idx = Component type id]
  // [Pool idx = Entity id]
  std::vector<std::shared_ptr<IPool>> componentPools;

  // INFO:
  // The signature lets us know which components are turned "on" for an entity
  // [Vector index = Entity id]
  std::vector<Signature> entityComponentSignatures;

  // INFO:
  // Map of active systems
  // [Map index = System type id]
  std::unordered_map<std::type_index, std::shared_ptr<System>> systems;

  // INFO: set of entities that are flagged to be added or removed in the next
  // registry Update()
  std::set<Entity> entitiesToBeAdded;
  std::set<Entity> entitiesToBeKilled;

  // INFO: List of free entity ids that were previously removed
  std::deque<int> freeIds;

public:
  Registry() { Logger::Log("Registry constructor called!"); }
  ~Registry() { Logger::Log("Registry destructor called!"); }

  void Update();

  Entity CreateEntity();
  void KillEntity(Entity entity);

  template <typename TComponent, typename... TArgs>
  void AddComponent(Entity entity, TArgs &&...args);
  template <typename TComponent> void RemoveComponent(Entity entity);
  template <typename TComponent> bool HasComponent(Entity entity) const;
  template <typename TComponent> TComponent &GetComponent(Entity entity) const;

  template <typename TSystem, typename... TArgs>
  void AddSystem(TArgs &&...args);
  template <typename TSystem> void RemoveSystem();
  template <typename TSystem> bool HasSystem() const;
  template <typename TSystem> TSystem &GetSystem() const;

  void AddEntityToSystems(Entity entity);
  void RemoveEntityFromSystems(Entity entity);
};

template <typename TSystem, typename... TArgs>
void Registry::AddSystem(TArgs &&...args) {
  std::shared_ptr<TSystem> newSystem =
      std::make_shared<TSystem>(std::forward<TArgs>(args)...);
  systems.insert(std::make_pair(std::type_index(typeid(TSystem)), newSystem));
}

template <typename TSystem> void Registry::RemoveSystem() {
  auto system = systems.find(std::type_index(typeid(TSystem)));
  systems.erase(system);
}

template <typename TSystem> bool Registry::HasSystem() const {
  return systems.find(std::type_index(typeid(TSystem))) != systems.end();
}

template <typename TSystem> TSystem &Registry::GetSystem() const {
  auto system = systems.find(std::type_index(typeid(TSystem)));
  return *(std::static_pointer_cast<TSystem>(system->second));
}

template <typename TComponent, typename... TArgs>
void Registry::AddComponent(Entity entity, TArgs &&...args) {
  const auto componentId = Component<TComponent>::GetId();
  const auto entityId = entity.GetId();

  if (componentId >= static_cast<int>(componentPools.size())) {
    componentPools.resize(componentId + 1, nullptr);
  }

  if (!componentPools[componentId]) {
    std::shared_ptr<Pool<TComponent>> newComponentPool =
        std::make_shared<Pool<TComponent>>();
    componentPools[componentId] = newComponentPool;
  }

  std::shared_ptr<Pool<TComponent>> componentPool =
      std::static_pointer_cast<Pool<TComponent>>(componentPools[componentId]);

  if (entityId >= componentPool->GetSize()) {
    componentPool->Resize(numEntities);
  }

  TComponent newComponent(std::forward<TArgs>(args)...);

  componentPool->Set(entityId, newComponent);

  entityComponentSignatures[entityId].set(componentId);

  Logger::Log("Component [id = " + std::to_string(componentId) +
              "] was added to entity [id = " + std::to_string(entityId) + "]");
}

template <typename T> void Registry::RemoveComponent(Entity entity) {
  const auto componentId = Component<T>::GetId();
  const auto entityId = entity.GetId();

  entityComponentSignatures[entityId].set(componentId, false);

  Logger::Log("Component [id = " + std::to_string(componentId) +
              "] was removed from entity [id = " + std::to_string(entityId) +
              "]");
}

template <typename T> bool Registry::HasComponent(Entity entity) const {
  const auto componentId = Component<T>::GetId();
  const auto entityId = entity.GetId();

  return entityComponentSignatures[entityId].test(componentId);
}

template <typename TComponent>
TComponent &Registry::GetComponent(Entity entity) const {
  const auto componentId = Component<TComponent>::GetId();
  const auto entityId = entity.GetId();
  auto componentPool =
      std::static_pointer_cast<Pool<TComponent>>(componentPools[componentId]);
  return componentPool->Get(entityId);
}

template <typename TComponent, typename... TArgs>
void Entity::AddComponent(TArgs &&...args) {
  registry->AddComponent<TComponent>(*this, std::forward<TArgs>(args)...);
}

template <typename TComponent> void Entity::RemoveComponent() {
  registry->RemoveComponent<TComponent>(*this);
}

template <typename TComponent> bool Entity::HasComponent() const {
  return registry->HasComponent<TComponent>(*this);
}

template <typename TComponent> TComponent &Entity::GetComponent() const {
  return registry->GetComponent<TComponent>(*this);
}

#endif
