package roraima

Transform :: struct {
	position: Vec2,
	scale:    Vec2,
	rotation: f32,
}

RigidBody :: struct {
	velocity: Vec2,
}

Sprite :: struct {
	width:  i32,
	height: i32,
}

ComponentType :: enum {
	Transform = 0,
	RigidBody,
	Sprite,
}

Signature :: bit_set[ComponentType]

Component :: struct {
	id:   ComponentType,
	data: union {
		Transform,
		RigidBody,
		Sprite,
	},
}

new_transform :: proc(
	position: Vec2,
	scale: Vec2,
	rotation: f32,
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

new_sprite :: proc(width: i32, height: i32) -> (component: ^Component) {
	component = new(Component)
	component.id = .Sprite
	component.data = Sprite{width, height}

	return
}
