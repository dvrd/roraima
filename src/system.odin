package roraima

import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"

SystemType :: enum {
	Movement,
	Render,
}

System :: struct {
	id:                  SystemType,
	component_signature: Signature,
	entities:            [dynamic]^Entity,
}

new_system :: proc(type: SystemType) -> ^System {
	sys, err := new(System)

	if err != nil {
		error("could not allocate System struct")
		os.exit(1)
	}

	sys.id = type
	sys.entities = make([dynamic]^Entity)
	sys.component_signature = {}

	switch type {
	case .Render:
		require_component(sys, .Transform)
		require_component(sys, .Sprite)
	case .Movement:
		require_component(sys, .Transform)
		require_component(sys, .RigidBody)
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

require_component :: proc(system: ^System, component: ComponentType) {
	system.component_signature += {component}
}

update_movement :: proc(system: ^System, delta: f32) {
	for entity in system.entities {
		transform_component := get_component(entity, .Transform)
		rigid_body_component := get_component(entity, .RigidBody)

		if transform_component != nil && rigid_body_component != nil {
			transform := transform_component.data.(Transform)
			rigid_body := rigid_body_component.data.(RigidBody)

			transform.position.x += rigid_body.velocity.x * delta
			transform.position.y += rigid_body.velocity.y * delta

			transform_component.data = transform
			rigid_body_component.data = rigid_body

			inform(
				"Entity moved to [x = %v, y = %v]",
				transform.position.x,
				transform.position.y,
			)

		}
	}
}

update_render :: proc(system: ^System, renderer: ^SDL.Renderer) {
	for entity in system.entities {
		transform := get_component(entity, .Transform)
		sprite := get_component(entity, .Sprite)
		if transform != nil && sprite != nil {
			transform := transform.data.(Transform)
			sprite := sprite.data.(Sprite)
			obj_rect := SDL.Rect {
				cast(i32)transform.position.x,
				cast(i32)transform.position.y,
				sprite.width,
				sprite.height,
			}
			SDL.SetRenderDrawColor(renderer, 255, 255, 255, 255)
			SDL.RenderFillRect(renderer, &obj_rect)

		}
	}
}
