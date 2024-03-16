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
	Damage,
	KeyboardControl,
	CameraMovement,
}

System :: struct {
	id:                  SystemType,
	component_signature: Signature,
	entities:            [dynamic]^Entity,
}

new_system :: proc(type: SystemType) -> ^System {
	sys, err := new(System)

	if err != nil {
		error("%vnew_system:%v could not allocate System struct", PURPLE, END)
		os.exit(1)
	}

	sys.id = type
	sys.entities = make([dynamic]^Entity)
	sys.component_signature = {}

	#partial switch type {
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
	case .Damage:
		sys.component_signature = {.BoxCollider}
	case .KeyboardControl:
		sys.component_signature = {.KeyboardController, .Sprite, .RigidBody}
	case .CameraMovement:
		sys.component_signature = {.CameraFollow, .Transform}
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
	search: for i := 0; i < len(system.entities); i += 1 {
		if system.entities[i].id == entity.id {
			ordered_remove(&system.entities, i)
			break search
		}
	}
}

update_movement :: proc(system: ^System, delta: f64) {
	for entity in system.entities {
		transform := get_transform(entity)
		rigid_body := get_rigid_body(entity)
		transform.position += rigid_body.velocity * delta
	}
}

update_render :: proc(
	system: ^System,
	renderer: ^SDL.Renderer,
	asset_store: ^AssetStore,
	camera: ^SDL.Rect,
) {
	for entity in system.entities {
		transform := get_transform(entity)
		sprite := get_sprite(entity)

		dst_rect := SDL.Rect {
			i32(transform.position.x - f64(sprite.is_fixed ? 0 : camera.x)),
			i32(transform.position.y - f64(sprite.is_fixed ? 0 : camera.y)),
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
		animation := get_component(entity, .Animation).(^Animation)
		sprite := get_component(entity, .Sprite).(^Sprite)

		current_frame :=
			(((cast(i32)SDL.GetTicks() - animation.start_time) *
					animation.speed_rate) /
				1000) %
			animation.frames

		animation.current_frame = cast(i32)current_frame

		sprite.src_rect = SDL.Rect {
			sprite.width * current_frame,
			sprite.src_rect.y,
			sprite.width,
			sprite.height,
		}
	}
}

check_aabb_collision :: proc(
	a_transform, b_transform: ^Transform,
	a_collider, b_collider: ^BoxCollider,
) -> bool {
	a_x := a_transform.position.x + a_collider.offset.x
	a_y := a_transform.position.y + a_collider.offset.y
	b_x := b_transform.position.x + b_collider.offset.x
	b_y := b_transform.position.y + b_collider.offset.y

	check_1 := a_x < b_x + cast(f64)b_collider.width
	check_2 := b_x < a_x + cast(f64)a_collider.width
	check_3 := a_y < b_y + cast(f64)b_collider.height
	check_4 := b_y < a_y + cast(f64)a_collider.height

	return check_1 && check_2 && check_3 && check_4
}

update_collision :: proc(system: ^System, bus: ^EventBus) {
	for i := 0; i < len(system.entities); i += 1 {
		a := system.entities[i]

		a_transform := get_transform(a)
		a_collider := get_box_collider(a)
		for j := i + 1; j < len(system.entities); j += 1 {
			b := system.entities[j]

			if a.id == b.id {
				continue
			}

			b_transform := get_transform(b)
			b_collider := get_box_collider(b)

			has_collided := check_aabb_collision(
				a_transform,
				b_transform,
				a_collider,
				b_collider,
			)

			if has_collided {
				a_collider.color = {255, 255, 0, 255}
				b_collider.color = {255, 255, 0, 255}
				inform(
					"%vupdate_collision:%v %v is colliding with %v",
					PURPLE,
					END,
					a.id,
					b.id,
				)

				emit_event(
					bus,
					get_system(a.owner, .Damage),
					{.Collision, CollisionEvent{a, b}},
				)
			} else {
				a_collider.color = {255, 0, 0, 255}
				b_collider.color = {255, 0, 0, 255}
			}
		}
	}
}

update_render_collider :: proc(
	system: ^System,
	renderer: ^SDL.Renderer,
	camera: ^SDL.Rect,
) {
	for entity in system.entities {
		transform := get_transform(entity)
		collider := get_box_collider(entity)
		collider_rect := SDL.Rect {
			cast(i32)transform.position.x - camera.x,
			cast(i32)transform.position.y - camera.y,
			collider.width * cast(i32)transform.scale.x,
			collider.height * cast(i32)transform.scale.y,
		}
		SDL.SetRenderDrawColor(
			renderer,
			collider.color.r,
			collider.color.g,
			collider.color.b,
			collider.color.a,
		)
		SDL.RenderDrawRect(renderer, &collider_rect)
	}
}

update_camera_movement :: proc(
	system: ^System,
	camera: ^SDL.Rect,
	level_map: ^SDL.Rect,
) {
	for entity in system.entities {
		transform := get_transform(entity)

		if cast(i32)transform.position.x + (camera.w / 2) < level_map.w {
			camera.x = cast(i32)transform.position.x - (camera.w / 2)
		}

		if cast(i32)transform.position.y + (camera.h / 2) < level_map.h {
			camera.y = cast(i32)transform.position.y - (camera.h / 2)
		}

		// Clamp camera to screen boundaries
		camera.x = camera.x < 0 ? 0 : camera.x
		camera.y = camera.y < 0 ? 0 : camera.y
		camera.x = camera.x > camera.w ? camera.w : camera.x
		camera.y = camera.y > camera.h ? camera.h : camera.y

		inform(
			"%vupdate_camera_follow:%v camera position: %v, %v",
			PURPLE,
			END,
			camera.x,
			camera.y,
		)
	}
}

on_collision :: proc(system: ^System, data: EventData) {
	kill_entity(data.(CollisionEvent).a)
	kill_entity(data.(CollisionEvent).b)
	inform(
		"%von_collision:%v %v is colliding with %v",
		PURPLE,
		END,
		data.(CollisionEvent).a.id,
		data.(CollisionEvent).b.id,
	)
}

on_keypressed :: proc(system: ^System, data: EventData) {
	for entity in system.entities {
		controller := get_keyboard_controller(entity)
		sprite := get_sprite(entity)
		rigid_body := get_rigid_body(entity)

		event := data.(KeyPressedEvent)
		#partial switch event.symbol {
		case SDL.Keycode.UP, SDL.Keycode.w:
			rigid_body.velocity = controller.up
			sprite.src_rect.y = sprite.height * 0
		case SDL.Keycode.RIGHT, SDL.Keycode.d:
			rigid_body.velocity = controller.right
			sprite.src_rect.y = sprite.height * 1
		case SDL.Keycode.DOWN, SDL.Keycode.s:
			rigid_body.velocity = controller.down
			sprite.src_rect.y = sprite.height * 2
		case SDL.Keycode.LEFT, SDL.Keycode.a:
			rigid_body.velocity = controller.left
			sprite.src_rect.y = sprite.height * 3
		}
	}
}

subscribe_to_events :: proc(bus: ^EventBus, system_id: SystemType) {
	#partial switch system_id {
	case .KeyboardControl:
		subscribe_to_event(bus, .KeyPressed, on_keypressed)
	case .Damage:
		subscribe_to_event(bus, .Collision, on_collision)
	}
}
