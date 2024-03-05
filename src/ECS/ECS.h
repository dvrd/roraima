
#ifndef ECS_H
#define ECS_H

#include <bitset>
#include <typeindex>
#include <unordered_map>
#include <vector>

const unsigned int MAX_COMPONENTS = 32;

typedef std::bitset<MAX_COMPONENTS> Signature;

struct IComponent {
protected:
  static int nextId;
};

// INFO: Used to assign a unique id to a component type
template <typename T> class Component : public IComponent {
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
  int GetId() const;
  Entity &operator=(const Entity &other) = default;
  bool operator==(const Entity &other) const { return id == other.id; }
  bool operator!=(const Entity &other) const { return id != other.id; }
  bool operator>(const Entity &other) const { return id > other.id; }
  bool operator<(const Entity &other) const { return id < other.id; }
  bool operator>=(const Entity &other) const { return id >= other.id; }
  bool operator<=(const Entity &other) const { return id <= other.id; }
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
  std::vector<IPool *> componentPools;

  // INFO:
  // The signature lets us know which components are turned "on" for an entity
  // [Vector index = Entity id]
  std::vector<Signature> entityComponentSignatures;

  // INFO:
  // Map of active systems
  // [Map index = System type id]
  std::unordered_map<std::type_index, System *> systems;

public:
  Registry() = default;
  Entity CreateEntity();
  void KillEntity(Entity entity);
  void AddSystem();
  void AddComponent();
  void RemoveComponent();
};

template <typename TComponent> void System::RequireComponent() {
  const auto componentId = Component<TComponent>::GetId();
  componentSignature.set(componentId);
}

#endif
