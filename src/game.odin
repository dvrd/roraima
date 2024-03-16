package roraima

import "core:fmt"
import "core:log"
import "core:os"
import "core:time"
import SDL "vendor:sdl2"

FPS :: 60
MS_PER_SEC :: 1_000
MS_PER_FRAME :: MS_PER_SEC / FPS
NS_PER_SEC :: 100_000_000

Vec2 :: [2]f64

State :: struct {
	window:        ^SDL.Window,
	renderer:      ^SDL.Renderer,
	is_running:    bool,
	is_debug:      bool,
	screen:        [2]i32,
	ms_prev_frame: u32,
	clock:         struct {
		delta:       f64,
		delta_ms:    u32,
		last_frame:  u32,
		last_second: i64,
		fps:         u32,
		frames:      u32,
	},
	registry:      ^Registry,
	asset_store:   ^AssetStore,
	event_bus:     ^EventBus,
}

new_game :: proc() -> ^State {
	inform(
		"%vnew_game:%v Initializing game engine 'Roraima v1.0.0'",
		PURPLE,
		END,
	)

	game := new(State)
	game.is_running = false
	game.is_debug = false
	game.registry = new_registry()
	game.asset_store = new_asset_store()
	game.event_bus = new_event_bus()

	return game
}

initialize :: proc(game: ^State) {
	using game

	if (SDL.Init({.AUDIO, .VIDEO, .EVENTS}) != 0) {
		error("%vinitialize:%v could not initialize SDL.", PURPLE, END)
		os.exit(1)
	}
	displayMode: SDL.DisplayMode
	SDL.GetCurrentDisplayMode(0, &displayMode)

	screen = {displayMode.w, displayMode.h}
	window = SDL.CreateWindow(
		"Roraima v1.0.0",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		screen.x,
		screen.y,
		{.BORDERLESS},
	)
	if window == nil {
		error("%vinitialize:%v window bad", PURPLE, END)
		os.exit(1)
	}

	renderer = SDL.CreateRenderer(window, -1, {})
	if renderer == nil {
		error("%vinitialize:%v renderer bad", PURPLE, END)
		os.exit(1)
	}

	SDL.SetWindowFullscreen(window, {.FULLSCREEN})

	is_running = true
}

process_input :: proc(game: ^State) {
	using game

	event: SDL.Event
	loop: for SDL.PollEvent(&event) {
		#partial switch event.type {
		case .KEYDOWN:
			#partial switch event.key.keysym.sym {
			case .ESCAPE:
				is_running = false
			case .d:
				is_debug = !is_debug
			}
			emit_event(
				event_bus,
				{.KeyPressed, KeyPressedEvent{event.key.keysym.sym}},
			)
			break loop
		case .QUIT:
			is_running = false
		}
	}
}

setup :: proc(game: ^State) {
	using game

	add_system(registry, new_system(.Movement))
	add_system(registry, new_system(.Render))
	add_system(registry, new_system(.Animation))
	add_system(registry, new_system(.Collision))
	add_system(registry, new_system(.RenderCollider))
	add_system(registry, new_system(.Damage))
	add_system(registry, new_system(.KeyboardControl))

	add_texture(
		asset_store,
		renderer,
		"tank-image",
		"assets/images/tank-panther-right.png",
	)
	add_texture(
		asset_store,
		renderer,
		"truck-image",
		"assets/images/truck-ford-right.png",
	)
	add_texture(
		asset_store,
		renderer,
		"chopper-image",
		"assets/images/chopper.png",
	)
	add_texture(asset_store, renderer, "radar-image", "assets/images/radar.png")
	add_texture(
		asset_store,
		renderer,
		"tilemap-image",
		"assets/tilemaps/jungle.png",
	)

	tile_size: i32 = 32
	tile_scale := 2.25
	map_n_cols := 25
	map_n_rows := 20
	next := 0
	ch: byte
	data, ok := os.read_entire_file("assets/tilemaps/jungle.map");if !ok {
		error("could not open tilemap file.")
		os.exit(1)
	}

	for y := 0; y < map_n_rows; y += 1 {
		for x := 0; x < map_n_cols; x += 1 {
			ch = data[next]
			next += 1
			srcRectY := i32(ch - '0') * tile_size
			ch = data[next]
			next += 2
			srcRectX := i32(ch - '0') * tile_size
			tile := create_entity(registry)
			posX := cast(f64)x * cast(f64)tile_size * tile_scale
			posY := cast(f64)y * cast(f64)tile_size * tile_scale
			position := Vec2{posX, posY}
			scale := Vec2{tile_scale, tile_scale}
			add_component(tile, new_transform(position, scale, 0))
			add_component(
				tile,
				new_sprite(
					"tilemap-image",
					tile_size,
					tile_size,
					srcRectX,
					srcRectY,
					0,
				),
			)
		}
	}

	radar := create_entity(registry)
	add_component(radar, new_transform({f64(screen.x - 74), 10}, {1, 1}, 0))
	add_component(radar, new_sprite("radar-image", 64, 64, 0, 0, 1))
	add_component(radar, new_animation(8, 5))

	chopper := create_entity(registry)
	add_component(chopper, new_transform({10, 100}, {1, 1}, 0))
	add_component(chopper, new_rigid_body({100, 0}))
	add_component(chopper, new_sprite("chopper-image", 32, 32, 0, 0, 1))
	add_component(chopper, new_animation(2, 10))
	add_component(chopper, new_box_collider(32, 32))

	tank := create_entity(registry)
	add_component(tank, new_transform({100, 10}, {1, 1}, 0))
	add_component(tank, new_rigid_body({-10, 0}))
	add_component(tank, new_sprite("tank-image", 32, 32, 0, 0, 1))
	add_component(tank, new_box_collider(32, 32))

	truck := create_entity(registry)
	add_component(truck, new_transform({10, 10}, {1, 1}, 0))
	add_component(truck, new_rigid_body({10, 0}))
	add_component(truck, new_sprite("truck-image", 32, 32, 0, 0, 1))
	add_component(truck, new_box_collider(32, 32))

	clock = {
		fps        = FPS,
		frames     = 0,
		last_frame = 0,
		delta      = 0,
		delta_ms   = 0,
	}
}

update :: proc(game: ^State) {
	using game
	now := time.time_to_unix_nano(time.now())

	clock.delta_ms = SDL.GetTicks() - clock.last_frame
	clock.delta = cast(f64)(clock.delta_ms) / MS_PER_SEC

	clock.frames += 1

	if now - clock.last_second > NS_PER_SEC {
		clock.last_second = now
		clock.fps = clock.frames
		clock.frames = 0
		debug("FPS: %v", clock.fps)
	}

	clear(&event_bus.subscribers)
	subscribe_to_events(event_bus, .Damage)
	subscribe_to_events(event_bus, .KeyboardControl)

	update_registry(registry)

	animation_system := get_system(registry, .Animation)
	movement_system := get_system(registry, .Movement)
	collision_system := get_system(registry, .Collision)

	update_animation(animation_system)
	update_movement(movement_system, clock.delta)
	update_collision(collision_system, event_bus)

	clock.last_frame = SDL.GetTicks()
}

render :: proc(game: ^State) {
	using game

	SDL.SetRenderDrawColor(renderer, 21, 21, 21, 255)
	SDL.RenderClear(renderer)

	render_system := get_system(registry, .Render)

	update_render(render_system, renderer, asset_store)
	if is_debug {
		render_system := get_system(registry, .RenderCollider)
		update_render_collider(render_system, renderer)
	}


	SDL.RenderPresent(renderer)
}

run :: proc(game: ^State) {
	setup(game)
	for game.is_running {
		process_input(game)
		update(game)
		render(game)
	}
}

destroy_game :: proc(game: ^State) {
	using game

	destroy_registry(registry)
	delete_asset_store(asset_store)

	SDL.DestroyWindow(window)
	SDL.DestroyRenderer(renderer)
	SDL.Quit()

	inform("%vdestroy_game:%v Game stopped. Have a nice day!", PURPLE, END)
}
