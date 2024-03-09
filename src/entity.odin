package roraima

import "core:fmt"
import "core:os"

Entity :: struct {
	id:     int,
	owner:  ^Registry,
	sprite: Sprite,
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

	inform(fmt.tprintf("Entity created with [id = %v]", entity.id))

	n_entities += 1

	return entity
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
		entity.sprite = component.data.(Sprite)
	}


	if entity.id >= len(entity_component_signatures) {
		inject_at(&entity_component_signatures, entity.id, Signature{component.id})
	} else {
		entity_component_signatures[entity.id] += {component.id}
	}

	inform(
		fmt.tprintf(
			"Add: Component [id = %v] to Entity [id = %v]",
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
	component: ComponentType,
) -> ^Component {
	return entity.owner.component_pools[component][entity.id]
}
