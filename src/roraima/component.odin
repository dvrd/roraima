package roraima

import "core:os"
import SDL "vendor:sdl2"

Transform :: struct {
	position: Vec2,
	scale:    Vec2,
	rotation: f64,
}

new_transform :: proc(
	position := Vec2{0, 0},
	scale := Vec2{1, 1},
	rotation := 0.,
) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_transform: failed to create new Transform component")
		os.exit(1)
	}
	component.id = .Transform
	component.data, err = new(Transform)
	if err != nil {
		error("new_transform: failed to create new Transform component")
		os.exit(1)
	}
	component.data.(^Transform)^ = Transform{position, scale, rotation}
	return component
}

RigidBody :: struct {
	velocity: Vec2,
}

new_rigid_body :: proc(velocity := Vec2{0, 0}) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_rigid_body: failed to create new RigidBody component")
		os.exit(1)
	}
	component.id = .RigidBody
	component.data, err = new(RigidBody)
	if err != nil {
		error("new_rigid_body: failed to create new RigidBody component")
		os.exit(1)
	}
	component.data.(^RigidBody)^ = RigidBody{velocity}
	return component
}

Sprite :: struct {
	id:       string,
	width:    i32,
	height:   i32,
	z_idx:    i32,
	is_fixed: bool,
	src_rect: SDL.Rect,
}

new_sprite :: proc(
	id: string,
	width, height: i32,
	x: i32 = 0,
	y: i32 = 0,
	z_idx: i32 = 0,
	is_fixed := false,
) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_sprite: failed to create new Sprite component")
		os.exit(1)
	}
	component.id = .Sprite
	component.data, err = new(Sprite)
	if err != nil {
		error("new_sprite: failed to create new Sprite component")
		os.exit(1)
	}
	component.data.(^Sprite)^ = Sprite {
		id,
		width,
		height,
		z_idx,
		is_fixed,
		SDL.Rect{x = x, y = y, w = width, h = height},
	}
	return component
}

Animation :: struct {
	frames:        i32,
	current_frame: i32,
	speed_rate:    i32,
	is_loop:       bool,
	start_time:    i32,
}

new_animation :: proc(frames, speed_rate: i32, is_loop := true) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_animation: failed to create new Animation component")
		os.exit(1)
	}
	component.id = .Animation
	component.data, err = new(Animation)
	if err != nil {
		error("new_animation: failed to create new Animation component")
		os.exit(1)
	}
	component.data.(^Animation)^ = Animation {
		frames        = frames,
		current_frame = 1,
		speed_rate    = speed_rate,
		is_loop       = is_loop,
		start_time    = cast(i32)SDL.GetTicks(),
	}
	return component
}

BoxCollider :: struct {
	width:  i32,
	height: i32,
	offset: Vec2,
	color:  [4]u8,
}

new_box_collider :: proc(
	width: i32 = 0,
	height: i32 = 0,
	offset: Vec2 = {0, 0},
	color: [4]u8 = {255, 0, 0, 255},
) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_box_collider: failed to create new BoxCollider component")
		os.exit(1)
	}
	component.id = .BoxCollider
	component.data, err = new(BoxCollider)
	if err != nil {
		error("new_box_collider: failed to create new BoxCollider component")
		os.exit(1)
	}
	component.data.(^BoxCollider)^ = BoxCollider {
		width  = width,
		height = height,
		offset = offset,
		color  = color,
	}
	return component
}

KeyboardController :: struct {
	up:    Vec2,
	right: Vec2,
	down:  Vec2,
	left:  Vec2,
}

new_keyboard_controller :: proc(
	up: Vec2 = {0, 0},
	right: Vec2 = {0, 0},
	down: Vec2 = {0, 0},
	left: Vec2 = {0, 0},
) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error(
			"new_keyboard_controller: failed to create new KeyboardController component",
		)
		os.exit(1)
	}
	component.id = .KeyboardController
	component.data, err = new(KeyboardController)
	if err != nil {
		error(
			"new_keyboard_controller: failed to create new KeyboardController component",
		)
		os.exit(1)
	}
	component.data.(^KeyboardController)^ = KeyboardController {
		up    = up,
		right = right,
		down  = down,
		left  = left,
	}
	return component
}

CameraFollow :: struct {}

new_camera_follow :: proc() -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_camera_follow: failed to create new CameraFollow component")
		os.exit(1)
	}
	component.id = .CameraFollow
	component.data, err = new(CameraFollow)
	if err != nil {
		error("new_camera_follow: failed to create new CameraFollow component")
		os.exit(1)
	}
	return component
}

ParticleEmitter :: struct {
	velocity:    Vec2,
	frequency:   int,
	duration:    int,
	dmg:         int,
	is_friendly: bool,
	last_emit:   int,
}

new_particle_emitter :: proc(
	velocity: Vec2 = {0, 0},
	frequency := 0,
	duration := 10 * MILLISECOND,
	dmg := 10,
	is_friendly := false,
) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error(
			"new_particle_emitter: failed to create new ParticleEmitter component",
		)
		os.exit(1)
	}
	component.id = .ParticleEmitter
	component.data, err = new(ParticleEmitter)
	if err != nil {
		error("new_camera_follow: failed to create new ParticleEmitter component")
		os.exit(1)
	}
	component.data.(^ParticleEmitter)^ = ParticleEmitter {
		velocity,
		frequency,
		duration,
		dmg,
		is_friendly,
		int(SDL.GetTicks()),
	}
	return component
}

Health :: struct {
	hp: int,
}

new_health :: proc(hp := 0) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_health: failed to create new Health component")
		os.exit(1)
	}
	component.id = .Health
	component.data, err = new(Health)
	if err != nil {
		error("new_health: failed to create new Health component")
		os.exit(1)
	}
	component.data.(^Health)^ = Health{hp}
	return component
}

Particle :: struct {
	is_friendly: bool,
	dmg:         int,
	lifespan:    int,
	birth:       int,
}

new_particle :: proc(
	is_friendly := false,
	dmg := 0,
	lifespan := 0,
) -> ^Component {
	component, err := new(Component)
	if err != nil {
		error("new_particle: failed to create new Particle component")
		os.exit(1)
	}

	component.data, err = new(Particle)
	if err != nil {
		error("new_particle: failed to create new Particle component")
		os.exit(1)
	}

	component.id = .Particle
	component.data.(^Particle)^ = Particle {
		is_friendly = is_friendly,
		dmg         = dmg,
		lifespan    = lifespan,
		birth       = int(SDL.GetTicks()),
	}

	return component
}

ComponentType :: enum {
	Transform = 0,
	RigidBody,
	Sprite,
	Animation,
	BoxCollider,
	KeyboardController,
	CameraFollow,
	ParticleEmitter,
	Health,
	Particle,
}

ComponentData :: union {
	^Transform,
	^RigidBody,
	^Sprite,
	^Animation,
	^BoxCollider,
	^KeyboardController,
	^CameraFollow,
	^ParticleEmitter,
	^Health,
	^Particle,
}

Signature :: bit_set[ComponentType]

Component :: struct {
	id:   ComponentType,
	data: ComponentData,
}

delete_component :: proc(component: ^Component) {
	switch v in component.data {
	case ^Transform:
		free(v)
	case ^RigidBody:
		free(v)
	case ^Sprite:
		free(v)
	case ^Animation:
		free(v)
	case ^BoxCollider:
		free(v)
	case ^KeyboardController:
		free(v)
	case ^CameraFollow:
		free(v)
	case ^ParticleEmitter:
		free(v)
	case ^Health:
		free(v)
	case ^Particle:
		free(v)
	}
	free(component)
}
