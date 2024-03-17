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
	systems:                     map[SystemType]^System,
	entities_to_add:             [dynamic]^Entity,
	entities_to_kill:            [dynamic]^Entity,
	free_ids:                    ^q.Queue(int),
	entity_per_tag:              map[string]^Entity,
	tag_per_entity:              map[int]string,
	entities_per_group:          map[string][dynamic]^Entity,
	group_per_entity:            map[int]string,
}

new_registry :: proc() -> (reg: ^Registry, err: Error) {
	reg = new(Registry) or_return
	reg.n_entities = 0
	reg.component_pools = make([dynamic]Pool, 3) or_return
	reg.entity_component_signatures = make([dynamic]Signature) or_return
	reg.systems = make(map[SystemType]^System) or_return
	reg.entities_to_add = make([dynamic]^Entity) or_return
	reg.entities_to_kill = make([dynamic]^Entity) or_return
	reg.entity_per_tag = make(map[string]^Entity) or_return
	reg.tag_per_entity = make(map[int]string) or_return
	reg.entities_per_group = make(map[string][dynamic]^Entity) or_return
	reg.group_per_entity = make(map[int]string) or_return
	reg.free_ids = new(q.Queue(int)) or_return
	q.init(reg.free_ids)

	inform("%vnew_registry:%v constructed registry %v", PURPLE, END, reg)

	return
}

destroy_registry :: proc(registry: ^Registry) {
	using registry
	inform("%vdestroy_registry:%v Registry destructor called", PURPLE, END)

	for pool in component_pools {
		for component in pool {
			delete_component(component)
		}
		delete(pool)
	}
	delete(component_pools)
	delete(entity_component_signatures)

	delete(entities_to_add)
	delete(entities_to_kill)

	delete(entity_per_tag)
	delete(tag_per_entity)


	for _, group in entities_per_group {
		delete(group)
	}
	delete(entities_per_group)
	delete(group_per_entity)

	delete(systems)
	free(free_ids)
	free(registry)
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

get_entity_by_tag :: proc(registry: ^Registry, tag: string) -> ^Entity {
	using registry

	if ok := tag in entity_per_tag; !ok {
		error("%vget_entity_by_tag:%v tag [%v] not found", PURPLE, END, tag)
		os.exit(1)
	}

	return entity_per_tag[tag]
}

get_entity :: proc {
	get_entity_by_tag,
}

get_entities_by_group :: proc(
	registry: ^Registry,
	group: string,
) -> [dynamic]^Entity {
	using registry

	if ok := group in entities_per_group; !ok {
		error(
			"%vget_entities_by_group:%v group [%v] not found",
			PURPLE,
			END,
			group,
		)
		os.exit(1)
	}


	return entities_per_group[group]
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

		remove_tag(entity)
		remove_group(entity)
	}

	clear(&entities_to_kill)
}

add_system :: proc(registry: ^Registry, system: ^System) {
	using registry
	systems[system.id] = system
}

get_system :: proc(registry: ^Registry, id: SystemType) -> ^System {
	using registry
	if ok := id in systems; !ok {
		error("%vget_system:%v .%v not found", PURPLE, END, id)
		os.exit(1)
	}
	return systems[id]
}
