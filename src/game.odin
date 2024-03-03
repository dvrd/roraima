package roraima

import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"

State :: struct {
	window:     ^SDL.Window,
	renderer:   ^SDL.Renderer,
	is_running: bool,
}

initialize :: proc(game: ^State) {
	using game

	if (SDL.Init({.AUDIO, .VIDEO, .EVENTS, .TIMER}) != 0) {
		fmt.eprintln("ERROR: could not initialize SDL.")
		os.exit(1)
	}
	window = SDL.CreateWindow(
		"Roraima v1.0.0",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		800,
		900,
		{},
	);if window == nil {
		fmt.eprintln("ERROR: window bad")
		os.exit(1)
	}

	renderer = SDL.CreateRenderer(window, -1, {});if renderer == nil {
		fmt.eprintln("ERROR: renderer bad")
		os.exit(1)
	}

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
update :: proc(game: ^State) {}
render :: proc(game: ^State) {}

run :: proc(game: ^State) {
	for game.is_running {
		process_input(game)
		update(game)
		render(game)
	}
}

destroy :: proc(game: ^State) {
	using game
	SDL.DestroyWindow(window)
	SDL.DestroyRenderer(renderer)
}
