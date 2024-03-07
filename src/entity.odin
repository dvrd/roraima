package roraima

import "core:fmt"
import "core:os"

Entity :: struct {
	id:    int,
	owner: ^Registry,
}

create_entity :: proc(registry: ^Registry) -> ^Entity {
	using registry

	if (n_entities >= cap(entity_component_signatures)) {
		resize(&entity_component_signatures, n_entities + 1)
	}

	entity, err := new(Entity)
	if err != nil {
		error("could not allocate Entity struct")
		os.exit(1)
	}
	entity.id = n_entities
	entity.owner = registry

	append(&entities_to_add, entity)

	inform(fmt.tprintf("Entity created with id = %v", entity.id))

	n_entities += 1

	return entity
}

add_component :: proc(entity: ^Entity, component: ^Component) {
	using entity.owner

	component_id := int(component.id)
	if (component_id >= cap(component_pools)) {
		resize(&component_pools, component_id + 1)
	}

	if component_pools[component_id] == nil {
		new_component_pool := make(Pool)
		inject_at(&component_pools, component_id, new_component_pool)
	}

	component_pool := component_pools[component_id]

	if entity.id >= cap(component_pool) {
		resize(&component_pool, n_entities + 1)
	}

	inject_at(&component_pool, entity.id, component)

	entity.owner.component_pools[component_id] = component_pool

	entity_component_signatures[entity.id] += {component.id}

	inform(
		fmt.tprintf(
			"Component [id = %v] added to entity [id = %v]",
			component.id,
			entity.id,
		),
	)
}

remove_component :: proc(entity: ^Entity, component: ^Component) {
	entity.owner.entity_component_signatures[entity.id] -= {component.id}
}

has_component :: proc(entity: ^Entity, component: ^Component) -> bool {
	return component.id in entity.owner.entity_component_signatures[entity.id]
}

get_component :: proc(
	entity: ^Entity,
	component: ComponentType,
) -> ^Component {
	return entity.owner.component_pools[int(component)][entity.id]
}
