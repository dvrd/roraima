package roraima

import "core:fmt"
import "core:log"
import "core:os"
import "core:time"
import SDL "vendor:sdl2"

FPS :: 60
MILLISECOND :: 1_000
MS_PER_FRAME :: MILLISECOND / FPS
NS_PER_SEC :: 100_000_000

Vec2 :: [2]f64
InitSystems :: bit_set[SystemType]
INIT_ALL_SYSTEMS :: InitSystems {
	.Movement,
	.Render,
	.Animation,
	.Collision,
	.RenderCollider,
	.Damage,
	.KeyboardControl,
	.CameraMovement,
	.ParticleEmit,
	.ParticleLifeCycle,
}

State :: struct {
	window:          ^SDL.Window,
	renderer:        ^SDL.Renderer,
	camera:          SDL.Rect,
	level_map:       SDL.Rect,
	is_running:      bool,
	is_debug:        bool,
	ms_prev_frame:   u32,
	clock:           struct {
		delta:       f64,
		delta_ms:    u32,
		last_frame:  u32,
		last_second: i64,
		fps:         u32,
		frames:      u32,
	},
	registry:        ^Registry,
	asset_store:     ^AssetStore,
	event_bus:       ^EventBus,
	enabled_systems: InitSystems,
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

init_game :: proc(game: ^State) {
	using game

	if (SDL.Init(SDL.INIT_EVERYTHING) != 0) {
		error("%vinitialize:%v could not initialize SDL.", PURPLE, END)
		os.exit(1)
	}
	displayMode: SDL.DisplayMode
	SDL.GetCurrentDisplayMode(0, &displayMode)

	camera = {
		x = 0,
		y = 0,
		w = displayMode.w,
		h = displayMode.h,
	}

	window = SDL.CreateWindow(
		"Roraima v1.0.0",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		camera.w,
		camera.h,
		{.BORDERLESS, .FULLSCREEN},
	)
	if window == nil {
		error("%vinitialize:%v window bad", PURPLE, END)
		os.exit(1)
	}

	renderer = SDL.CreateRenderer(window, -1, {.ACCELERATED, .PRESENTVSYNC})
	if renderer == nil {
		error("%vinitialize:%v renderer bad", PURPLE, END)
		os.exit(1)
	}

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
			case .TAB:
				is_debug = !is_debug
			}
			emit_event(
				event_bus,
				get_system(registry, .KeyboardControl),
				{.KeyPressed, KeyPressedEvent{event.key.keysym.sym}},
			)
			break loop
		case .QUIT:
			is_running = false
		}
	}
}

setup_game :: proc(
	game: ^State,
	flags: InitSystems,
	callback: proc(game: ^State),
) {
	using game

	if .Movement in flags {
		add_system(registry, new_system(.Movement))
	}

	if .Render in flags {
		add_system(registry, new_system(.Render))
	}

	if .Animation in flags {
		add_system(registry, new_system(.Animation))
	}

	if .Collision in flags {
		add_system(registry, new_system(.Collision))
	}

	if .RenderCollider in flags {
		add_system(registry, new_system(.RenderCollider))
	}

	if .Damage in flags {
		add_system(registry, new_system(.Damage))
	}

	if .KeyboardControl in flags {
		add_system(registry, new_system(.KeyboardControl))
	}

	if .CameraMovement in flags {
		add_system(registry, new_system(.CameraMovement))
	}

	if .ParticleEmit in flags {
		add_system(registry, new_system(.ParticleEmit))
	}

	if .ParticleLifeCycle in flags {
		add_system(registry, new_system(.ParticleLifeCycle))
	}

	add_texture(
		asset_store,
		renderer,
		"bullet-image",
		"assets/images/bullet.png",
	)

	clock = {
		fps        = FPS,
		frames     = 0,
		last_frame = 0,
		delta      = 0,
		delta_ms   = 0,
	}

	enabled_systems = flags

	callback(game)
}

update_game :: proc(game: ^State) {
	using game
	now := time.time_to_unix_nano(time.now())

	clock.delta_ms = SDL.GetTicks() - clock.last_frame
	clock.delta = cast(f64)(clock.delta_ms) / MILLISECOND

	clock.frames += 1

	if now - clock.last_second > NS_PER_SEC {
		clock.last_second = now
		clock.fps = clock.frames
		clock.frames = 0
		debug("FPS: %v", clock.fps)
	}

	clear(&event_bus.subscribers)

	if .Damage in enabled_systems {
		subscribe_to_events(event_bus, .Damage)
	}

	if .KeyboardControl in enabled_systems {
		subscribe_to_events(event_bus, .KeyboardControl)
	}

	if .ParticleEmit in enabled_systems {
		subscribe_to_events(event_bus, .ParticleEmit)
	}

	update_registry(registry)

	if .Animation in enabled_systems {
		animation_system := get_system(registry, .Animation)
		update_animation(animation_system)
	}

	if .Movement in enabled_systems {
		movement_system := get_system(registry, .Movement)
		update_movement(movement_system, clock.delta)
	}

	if .ParticleEmit in enabled_systems {
		particle_emit_system := get_system(registry, .ParticleEmit)
		update_particle_emit(particle_emit_system)
	}

	if .Collision in enabled_systems {
		collision_system := get_system(registry, .Collision)
		update_collision(collision_system, event_bus)
	}

	if .CameraMovement in enabled_systems {
		camera_movement_system := get_system(registry, .CameraMovement)
		update_camera_movement(camera_movement_system, &camera, &level_map)
	}

	if .ParticleLifeCycle in enabled_systems {
		particle_lifecyle := get_system(registry, .ParticleLifeCycle)
		update_particle_life_cycle(particle_lifecyle)
	}

	clock.last_frame = SDL.GetTicks()
}

render_game :: proc(game: ^State) {
	using game

	SDL.SetRenderDrawColor(renderer, 21, 21, 21, 255)
	SDL.RenderClear(renderer)

	if .RenderCollider in enabled_systems {
		render_system := get_system(registry, .Render)
		update_render(render_system, renderer, asset_store, &camera)
	}

	if is_debug && .RenderCollider in enabled_systems {
		render_system := get_system(registry, .RenderCollider)
		update_render_collider(render_system, renderer, &camera)
	}

	SDL.RenderPresent(renderer)
}

run_game :: proc(
	game: ^State,
	flags: InitSystems,
	setup_callback: proc(game: ^State),
) {
	setup_game(game, flags, setup_callback)
	for game.is_running {
		process_input(game)
		update_game(game)
		render_game(game)
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
