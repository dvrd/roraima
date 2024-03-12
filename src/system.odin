package roraima

import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"

SystemType :: enum {
	Movement,
	Render,
	Animation,
	Collision,
	RenderCollider,
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
	case .Animation:
		sys.component_signature = {.Animation, .Sprite}
	case .Collision:
		sys.component_signature = {.Transform, .BoxCollider}
	case .RenderCollider:
		sys.component_signature = {.Transform, .BoxCollider}
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

		transform := transform_component.data.(^Transform)
		rigid_body := rigid_body_component.data.(^RigidBody)

		transform.position.x += rigid_body.velocity.x * delta
		transform.position.y += rigid_body.velocity.y * delta

		transform_component.data = transform
		rigid_body_component.data = rigid_body
	}
}

update_render :: proc(
	system: ^System,
	renderer: ^SDL.Renderer,
	asset_store: ^AssetStore,
) {
	for entity in system.entities {
		transform := get_component(entity, .Transform).data.(^Transform)
		sprite := get_component(entity, .Sprite).data.(^Sprite)
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

update_animation :: proc(system: ^System) {
	for entity in system.entities {
		animation := get_component(entity, .Animation)
		sprite := get_component(entity, .Sprite)

		if animation == nil || sprite == nil {
			error(
				"missing data in entity %v (animation: %v | sprite: %v)",
				entity.id,
				animation,
				sprite,
			)
		}

		animation_data := animation.data.(^Animation)
		sprite_data := sprite.data.(^Sprite)

		current_frame :=
			(((cast(i32)SDL.GetTicks() - animation_data.start_time) *
					animation_data.speed_rate) /
				1000) %
			animation_data.frames

		animation_data.current_frame = cast(i32)current_frame
		animation.data = animation_data

		sprite_data.src_rect = SDL.Rect {
			sprite_data.width * current_frame,
			sprite_data.src_rect.y,
			sprite_data.width,
			sprite_data.height,
		}
		sprite.data = sprite_data
	}
}

check_aabb_collision :: proc(a, b: ^Entity) -> bool {
	a_transform := get_component(a, .Transform).data.(^Transform)
	a_collider := get_component(a, .BoxCollider).data.(^BoxCollider)

	b_transform := get_component(b, .Transform).data.(^Transform)
	b_collider := get_component(b, .BoxCollider).data.(^BoxCollider)

	check_1 :=
		a_transform.position.x < b_transform.position.x + cast(f64)b_collider.width
	check_2 :=
		a_transform.position.x + cast(f64)a_collider.width > b_transform.position.x
	check_3 :=
		a_transform.position.y <
		b_transform.position.y + cast(f64)b_collider.height
	check_4 :=
		a_transform.position.y + cast(f64)a_collider.height >
		b_transform.position.y

	return check_1 && check_2 && check_3 && check_4
}

update_collision :: proc(system: ^System) {
	for i := 0; i < len(system.entities); i += 1 {
		a := system.entities[i]

		for j := i + 1; j < len(system.entities); j += 1 {
			b := system.entities[j]

			has_collided := check_aabb_collision(a, b)

			if has_collided {
				inform("Entity %v is colliding with entity %v", a.id, b.id)
			}
		}
	}
}

update_render_collider :: proc(system: ^System, renderer: ^SDL.Renderer) {
	for entity in system.entities {
		transform := get_component(entity, .Transform).data.(^Transform)
		collider := get_component(entity, .BoxCollider).data.(^BoxCollider)
		collider_rect := SDL.Rect {
			cast(i32)transform.position.x,
			cast(i32)transform.position.y,
			collider.width,
			collider.height,
		}
		SDL.SetRenderDrawColor(renderer, 255, 0, 0, 255)
		SDL.RenderDrawRect(renderer, &collider_rect)
	}
}
