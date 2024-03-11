package roraima

import "core:fmt"
import "core:os"
import "core:slice"

Pool :: [dynamic]^Component

Registry :: struct {
	n_entities:                  int,
	component_pools:             [dynamic]Pool,
	entity_component_signatures: [dynamic]Signature,
	systems:                     ^map[SystemType]^System,
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
	reg.component_pools = make([dynamic]Pool, 3)
	reg.entity_component_signatures = make([dynamic]Signature)
	reg.systems = new(map[SystemType]^System)
	reg.entities_to_add = make([dynamic]^Entity)
	reg.entities_to_kill = make([dynamic]^Entity)

	inform("Registry constructor called")

	return reg
}

destroy_registry :: proc(registry: ^Registry) {
	using registry

	for pool in component_pools {
		for component in pool {
			if component != nil {
				delete_component(component)
			}
		}
		delete(pool)
	}
	delete(component_pools)
	delete(entity_component_signatures)
	delete(entities_to_add)
	delete(entities_to_kill)
	free(systems)
	free(registry)

	inform("Registry destructor called")
}

register_entity :: proc(registry: ^Registry, entity: ^Entity) {
	using registry

	signature := entity_component_signatures[entity.id]
	for _, system in systems {
		sys_signature := system.component_signature
		is_interested := (signature & sys_signature) == sys_signature
		if is_interested {
			add_entity_to_system(system, entity)
		}
	}
}

update_registry :: proc(registry: ^Registry) {
	using registry

	sorted_entities := entities_to_add[:]
	slice.sort_by(sorted_entities, proc(a, b: ^Entity) -> bool {
		return a.sprite.z_idx < b.sprite.z_idx
	})

	for entity in sorted_entities {
		register_entity(registry, entity)
	}

	clear(&entities_to_add)

	// for entity in entities_to_kill {
	// 	kill_entity(registry, entity)
	// }
	//
	// entities_to_kill.clear()
}

add_system :: proc(registry: ^Registry, system: ^System) {
	using registry
	systems[system.id] = system
}

get_system :: proc(registry: ^Registry, id: SystemType) -> ^System {
	using registry
	return systems[id]
}
