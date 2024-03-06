package roraima

import "core:os"

System :: struct {
	component_signature: Signature,
	entities:            [dynamic]^Entity,
}

new_system :: proc() -> ^System {
	sys, err := new(System);if err == nil {
		error("could not allocate System struct")
		os.exit(1)
	}

	return sys
}

destroy_system :: proc(system: ^System) {
	delete(system.entities)
	free(system)
}

add_entity_to_system :: proc(system: ^System, entity: ^Entity) {
	append(&system.entities, entity)
}

remove_entity_from_system :: proc(system: ^System, entity: ^Entity) {
	search: for e in system.entities {
		if e.id == entity.id {
			ordered_remove(&system.entities, e.id)
			break search
		}
	}
}

require_component :: proc(system: ^System, component: ^Component) {
	system.component_signature += {component.id}
}
