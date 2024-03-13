package roraima

import q "core:container/queue"
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
	free_ids:                    ^q.Queue(int),
}

new_registry :: proc() -> ^Registry {
	reg, err := new(Registry)
	if err != nil {
		error("%vnew_registry:%v could not allocate Registry struct", PURPLE, END)
		os.exit(1)
	}
	reg.n_entities = 0
	reg.component_pools = make([dynamic]Pool, 3)
	reg.entity_component_signatures = make([dynamic]Signature)
	reg.systems, err = new(map[SystemType]^System)
	if err != nil {
		error(
			"%vnew_registry:%v could not allocate Registry systems map",
			PURPLE,
			END,
		)
		os.exit(1)
	}

	reg.entities_to_add = make([dynamic]^Entity)
	reg.entities_to_kill = make([dynamic]^Entity)
	reg.free_ids, err = new(q.Queue(int))
	if err != nil {
		error(
			"%vnew_registry:%v could not allocate Registry free ids queue",
			PURPLE,
			END,
		)
		os.exit(1)
	}
	q.init(reg.free_ids)

	inform("%vnew_registry:%v constructed registry %v", PURPLE, END, reg)

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
	free(free_ids)
	free(registry)

	inform("%vdestroy_registry:%v Registry destructor called", PURPLE, END)
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

unregister_entity :: proc(registry: ^Registry, entity: ^Entity) {
	using registry

	for _, system in systems {
		remove_entity_from_system(system, entity)
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

	for entity in entities_to_kill {
		unregister_entity(registry, entity)
		entity_component_signatures[entity.id] = {}
		q.push_back(free_ids, entity.id)
	}

	clear(&entities_to_kill)
}

add_system :: proc(registry: ^Registry, system: ^System) {
	using registry
	systems[system.id] = system
}

get_system :: proc(registry: ^Registry, id: SystemType) -> (system: ^System) {
	using registry
	system = systems[id]
	if system == nil {
		error("%vget_system:%v system %v not found", PURPLE, END, id)
		os.exit(1)
	}
	return
}
