package roraima

import "core:fmt"
import "core:os"

Entity :: struct {
	id: int,
}

create_entity :: proc(registry: ^Registry) -> ^Entity {
	using registry

	n_entities += 1

	if (n_entities >= cap(entity_component_signatures)) {
		resize(&entity_component_signatures, n_entities + 1)
	}

	entity, err := new(Entity)
	if err != nil {
		error("could not allocate Entity struct")
		os.exit(1)
	}
	entity.id = n_entities

	append(&entities_to_add, entity)

	inform(fmt.tprintf("Entity created with id = %v", entity.id))

	return entity
}
