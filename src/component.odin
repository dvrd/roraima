package roraima

import SDL "vendor:sdl2"

Transform :: struct {
	position: Vec2,
	scale:    Vec2,
	rotation: f64,
}

RigidBody :: struct {
	velocity: Vec2,
}

Sprite :: struct {
	id:       string,
	width:    i32,
	height:   i32,
	z_idx:    i32,
	src_rect: SDL.Rect,
}

Animation :: struct {
	frames:        i32,
	current_frame: i32,
	speed_rate:    i32,
	is_loop:       bool,
	start_time:    i32,
}

ComponentType :: enum {
	Transform = 0,
	RigidBody,
	Sprite,
	Animation,
}

Signature :: bit_set[ComponentType]

Component :: struct {
	id:   ComponentType,
	data: union {
		Transform,
		RigidBody,
		Sprite,
		Animation,
	},
}

new_transform :: proc(
	position: Vec2,
	scale: Vec2,
	rotation: f64,
) -> (
	component: ^Component,
) {
	component = new(Component)
	component.id = .Transform
	component.data = Transform{position, scale, rotation}

	return
}

new_rigid_body :: proc(velocity: Vec2) -> (component: ^Component) {
	component = new(Component)
	component.id = .RigidBody
	component.data = RigidBody{velocity}

	return
}

new_sprite :: proc(
	id: string,
	width, height, x, y, z_idx: i32,
) -> (
	component: ^Component,
) {
	component = new(Component)
	component.id = .Sprite
	component.data = Sprite {
		id,
		width,
		height,
		z_idx,
		SDL.Rect{x, y, width, height},
	}

	return
}

new_animation :: proc(
	frames, speed_rate: i32,
	is_loop: bool,
) -> (
	component: ^Component,
) {
	component = new(Component)
	component.id = .Animation
	component.data = Animation {
		frames        = frames,
		current_frame = 1,
		speed_rate    = speed_rate,
		is_loop       = is_loop,
		start_time    = cast(i32)SDL.GetTicks(),
	}

	return
}
