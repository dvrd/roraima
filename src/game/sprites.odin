package game

import "src:roraima"

setup_player :: proc(game: ^roraima.State) {
	using game
	using roraima

	add_texture(
		asset_store,
		renderer,
		"chopper-image",
		"assets/images/chopper-spritesheet.png",
	)

	chopper := create_entity(registry)
	tag(chopper, "player")
	add_component(chopper, new_transform({100, 100}, {1, 1}, 0))
	add_component(chopper, new_rigid_body({0, 0}))
	add_component(
		chopper,
		new_sprite("chopper-image", 32, 32, y = 32, z_idx = 1),
	)
	add_component(chopper, new_animation(2, 10))
	add_component(chopper, new_particle_emitter({450, 450}, is_friendly = true))
	add_component(chopper, new_box_collider(32, 32))
	add_component(
		chopper,
		new_keyboard_controller({0, -200}, {200, 0}, {0, 200}, {-200, 0}),
	)
	add_component(chopper, new_camera_follow())
	add_component(chopper, new_health(100))
}

setup_tank :: proc(game: ^roraima.State) {
	using game
	using roraima

	add_texture(
		asset_store,
		renderer,
		"tank-image",
		"assets/images/tank-panther-right.png",
	)

	tank := create_entity(registry)
	group(tank, "enemies")
	add_component(tank, new_transform({500, 10}, {1, 1}, 0))
	add_component(tank, new_rigid_body({0, 0}))
	add_component(tank, new_sprite("tank-image", 32, 32, z_idx = 1))
	add_component(tank, new_box_collider(32, 32))
	// add_component(tank, new_particle_emitter({100, 0}, 5_000, 3_000))
	add_component(tank, new_health(100))
}

setup_truck :: proc(game: ^roraima.State) {
	using game
	using roraima

	add_texture(
		asset_store,
		renderer,
		"truck-image",
		"assets/images/truck-ford-right.png",
	)

	truck := create_entity(registry)
	group(truck, "enemies")
	add_component(truck, new_transform({150, 500}, {1, 1}, 0))
	add_component(truck, new_rigid_body({0, 0}))
	add_component(truck, new_sprite("truck-image", 32, 32, z_idx = 1))
	add_component(truck, new_box_collider(32, 32))
	// add_component(truck, new_particle_emitter({0, 100}, 2_000, 5_000))
	add_component(truck, new_health(100))
}

setup_radar :: proc(game: ^roraima.State) {
	using game
	using roraima

	add_texture(asset_store, renderer, "radar-image", "assets/images/radar.png")

	radar := create_entity(registry)
	add_component(radar, new_transform({f64(camera.w - 74), 10}))
	add_component(
		radar,
		new_sprite("radar-image", 64, 64, z_idx = 1, is_fixed = true),
	)
	add_component(radar, new_animation(8, 5))
}
