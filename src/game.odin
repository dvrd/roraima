package roraima

import "core:fmt"
import "core:log"
import "core:os"
import "core:time"
import SDL "vendor:sdl2"
import "vendor:sdl2/image"

FPS :: 60
MS_PER_SEC :: 1_000
MS_PER_FRAME :: MS_PER_SEC / FPS
NS_PER_SEC :: 100_000_000

Vec2 :: [2]f32

State :: struct {
	window:        ^SDL.Window,
	renderer:      ^SDL.Renderer,
	is_running:    bool,
	screen:        [2]i32,
	ms_prev_frame: u32,
	clock:         struct {
		delta:       f32,
		delta_ms:    u32,
		last_frame:  u32,
		last_second: i64,
		fps:         u32,
		frames:      u32,
	},
	registry:      ^Registry,
}

new_game :: proc() -> ^State {
	inform("Initializing game engine 'Roraima v1.0.0'")

	registry := new_registry()
	game := new(State)
	game.registry = registry
	game.is_running = false

	return game
}

initialize :: proc(game: ^State) {
	using game

	if (SDL.Init({.AUDIO, .VIDEO, .EVENTS}) != 0) {
		error("could not initialize SDL.")
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
		error("window bad")
		os.exit(1)
	}

	renderer = SDL.CreateRenderer(window, -1, {})
	if renderer == nil {
		error("renderer bad")
		os.exit(1)
	}

	SDL.SetWindowFullscreen(window, {.FULLSCREEN})

	is_running = true
}

process_input :: proc(game: ^State) {
	using game

	event: SDL.Event
	for SDL.PollEvent(&event) {
		#partial switch event.type {
		case .KEYDOWN:
			#partial switch event.key.keysym.sym {
			case .ESCAPE:
				is_running = false
			}
		case .QUIT:
			is_running = false
		}
	}
}

setup :: proc(game: ^State) {
	using game

	add_system(registry, new_system(.Movement))
	add_system(registry, new_system(.Render))

	tank := create_entity(registry)
	truck := create_entity(registry)

	add_component(tank, new_transform({10, 10}, {1, 1}, 0))
	add_component(tank, new_rigid_body({100, 0}))
	add_component(tank, new_sprite(10, 10))

	add_component(truck, new_transform({10, 20}, {1, 1}, 0))
	add_component(truck, new_rigid_body({120, 0}))
	add_component(truck, new_sprite(10, 10))

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
	clock.delta = cast(f32)(clock.delta_ms) / MS_PER_SEC

	clock.frames += 1

	if now - clock.last_second > NS_PER_SEC {
		clock.last_second = now
		clock.fps = clock.frames
		clock.frames = 0
		debug("FPS: %v", clock.fps)
	}

	movement_system := get_system(registry, .Movement)
	update_movement(movement_system, clock.delta)

	update_registry(registry)

	clock.last_frame = SDL.GetTicks()
}

render :: proc(game: ^State) {
	using game

	SDL.SetRenderDrawColor(renderer, 21, 21, 21, 255)
	SDL.RenderClear(renderer)

	render_system := get_system(registry, .Render)
	update_render(render_system, renderer)

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

	SDL.DestroyWindow(window)
	SDL.DestroyRenderer(renderer)
	SDL.Quit()

	inform("Game stopped. Have a nice day!")
}
