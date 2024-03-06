package roraima

import "core:fmt"
import "core:os"

Pool :: [dynamic]^Component

Registry :: struct {
	n_entities:                  int,
	component_pools:             [dynamic]Pool,
	entity_component_signatures: [dynamic]Signature,
	systems:                     map[int]^System,
	entities_to_add:             [dynamic]^Entity,
	entities_to_kill:            [dynamic]^Entity,
}

new_registry :: proc() -> ^Registry {
	reg, err := new(Registry)
	if err != nil {
		error("could not allocate Registry struct")
		os.exit(1)
	}
	reg.n_entities = 0

	return reg
}

destroy_registry :: proc(registry: ^Registry) {
	using registry

	delete(component_pools)
	delete(entity_component_signatures)
	delete(entities_to_add)
	delete(entities_to_kill)
	delete(systems)
	free(registry)
}

register_entity :: proc(registry: ^Registry, entity: ^Entity) {
	using registry

	entity_component_signature := entity_component_signatures[entity.id]
	for key, system in systems {
		system_component_signature := system.component_signature
		is_interested :=
			(entity_component_signature & system_component_signature) ==
			system_component_signature
		if is_interested {
			add_entity_to_system(system, entity)
		}
	}
}

update_registry :: proc(registry: ^Registry) {
	using registry

	for entity in entities_to_add {
		register_entity(registry, entity)
	}

	clear(&entities_to_add)

	// for entity in entities_to_kill {
	// 	kill_entity(registry, entity)
	// }
	//
	// entities_to_kill.clear()
}

add_component :: proc(
	registry: ^Registry,
	entity: ^Entity,
	component: ^Component,
) {
	using registry

	if (component.id >= cap(component_pools)) {
		resize(&component_pools, component.id + 1)
	}

	if component_pools[component.id] == nil {
		new_component_pool := make(Pool)
		component_pools[component.id] = new_component_pool
	}

	component_pool := component_pools[component.id]

	if entity.id >= cap(component_pool) {
		resize(&component_pool, n_entities)
	}

	component_pool[entity.id] = component

	entity_component_signatures[entity.id] += {component.id}
}

remove_component :: proc(
	registry: ^Registry,
	component: ^Component,
	entity: ^Entity,
) {
	using registry
	entity_component_signatures[entity.id] -= {component.id}
}

has_component :: proc(
	registry: ^Registry,
	component: ^Component,
	entity: ^Entity,
) -> bool {
	using registry
	return component.id in entity_component_signatures[entity.id]
}
