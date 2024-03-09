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
		sys.component_signature = {.Transform, .Sprite}
	case .Movement:
		sys.component_signature = {.Transform, .RigidBody}
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

update_movement :: proc(system: ^System, delta: f64) {
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

			debug(
				"Entity moved to [x = %v, y = %v]",
				transform.position.x,
				transform.position.y,
			)
		}
	}
}

update_render :: proc(
	system: ^System,
	renderer: ^SDL.Renderer,
	asset_store: ^AssetStore,
) {
	for entity in system.entities {
		transform := get_component(entity, .Transform)
		sprite := get_component(entity, .Sprite)
		if transform != nil && sprite != nil {
			transform := transform.data.(Transform)
			sprite := sprite.data.(Sprite)
			dst_rect := SDL.Rect {
				cast(i32)transform.position.x,
				cast(i32)transform.position.y,
				i32(cast(f64)sprite.width * transform.scale.x),
				i32(cast(f64)sprite.height * transform.scale.y),
			}

			SDL.RenderCopyEx(
				renderer,
				asset_store[sprite.id],
				&sprite.src_rect,
				&dst_rect,
				transform.rotation,
				nil,
				.NONE,
			)
		}
	}
}
