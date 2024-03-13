package roraima

import q "core:container/queue"
import "core:fmt"
import "core:os"

Entity :: struct {
	id:     int,
	owner:  ^Registry,
	sprite: ^Sprite,
}

create_entity :: proc(registry: ^Registry) -> ^Entity {
	using registry

	id: int
	ok: bool

	if free_ids.len == 0 {
		n_entities += 1
		id = n_entities
		if (id >= cap(entity_component_signatures)) {
			resize(&entity_component_signatures, id + 1)
		}
	} else {
		id, ok = q.pop_front_safe(free_ids);if !ok {
			error("%vcreate_entity:%v could not pop id from free_ids", PURPLE, END)
		}
	}

	entity, err := new(Entity);if err != nil {
		error("%vcreate_entity:%v could not allocate Entity struct", PURPLE, END)
		os.exit(1)
	}
	entity.id = id
	entity.owner = registry
	append(&entities_to_add, entity)

	inform("%vcreate_entity:%v created with [id = %v]", PURPLE, END, entity.id)

	return entity
}

kill_entity :: proc(entity: ^Entity) {
	append(&entity.owner.entities_to_kill, entity)
}

add_component :: proc(entity: ^Entity, component: ^Component) {
	using entity.owner

	component_id := int(component.id)
	if (component_id >= cap(component_pools)) {
		resize(&component_pools, component_id + 1)
	}

	if component_id >= len(component_pools) {
		new_component_pool := make(Pool)
		inject_at(&component_pools, component_id, new_component_pool)
	}

	if entity.id >= cap(component_pools[component_id]) {
		resize(&component_pools[component_id], n_entities + 1)
	}


	inject_at(&component_pools[component_id], entity.id, component)

	#partial switch component.id {
	case .Sprite:
		entity.sprite = component.data.(^Sprite)
	}

	if entity.id >= len(entity_component_signatures) {
		inject_at(&entity_component_signatures, entity.id, Signature{component.id})
	} else {
		entity_component_signatures[entity.id] += {component.id}
	}

	inform(
		fmt.tprintf(
			"%vadd_component:%v Component [id = %v] to Entity [id = %v]",
			PURPLE,
			END,
			component.id,
			entity.id,
		),
	)
}

remove_component :: proc(entity: ^Entity, component: ComponentType) {
	entity.owner.entity_component_signatures[entity.id] -= {component}
}

has_component :: proc(entity: ^Entity, component: ComponentType) -> bool {
	return component in entity.owner.entity_component_signatures[entity.id]
}

get_component :: proc(
	entity: ^Entity,
	id: ComponentType,
) -> (
	component: ^Component,
) {
	if int(id) >= len(entity.owner.component_pools) {
		error("%vget_component:%v Component Pool %v not found", PURPLE, END, id)
		os.exit(1)
	}

	pool := entity.owner.component_pools[id];if pool == nil {
		error("%vget_component:%v Component Pool %v not found", PURPLE, END, id)
		os.exit(1)
	}

	if entity.id >= len(pool) {
		error("%vget_component:%v Component %v not found", PURPLE, END, entity.id)
		os.exit(1)
	}

	component = pool[entity.id];if component == nil {
		error("%vget_component:%v Component %v not found", PURPLE, END, id)
		os.exit(1)
	}

	return
}
