package roraima

import "core:fmt"
import "core:os"
import SDL "vendor:sdl2"
import "vendor:sdl2/image"

Vec2 :: [2]i32

State :: struct {
	window:     ^SDL.Window,
	renderer:   ^SDL.Renderer,
	is_running: bool,
	screen:     Vec2,
}

initialize :: proc(game: ^State) {
	using game

	if (SDL.Init({.AUDIO, .VIDEO, .EVENTS}) != 0) {
		fmt.eprintln("ERROR: could not initialize SDL.")
		os.exit(1)
	}
	displayMode: SDL.DisplayMode
	SDL.GetCurrentDisplayMode(0, &displayMode)

	screen.x = displayMode.w
	screen.y = displayMode.h
	window = SDL.CreateWindow(
		"Roraima v1.0.0",
		SDL.WINDOWPOS_CENTERED,
		SDL.WINDOWPOS_CENTERED,
		screen.x,
		screen.y,
		{.BORDERLESS},
	);if window == nil {
		fmt.eprintln("ERROR: window bad")
		os.exit(1)
	}

	renderer = SDL.CreateRenderer(window, -1, {});if renderer == nil {
		fmt.eprintln("ERROR: renderer bad")
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

setup :: proc(game: ^State) {}

update :: proc(game: ^State) {}

render :: proc(game: ^State) {
	using game

	SDL.SetRenderDrawColor(renderer, 21, 21, 21, 255)
	SDL.RenderClear(renderer)

	// Draw a PNG texture
	surface := image.Load("./assets/images/tank-tiger-right.png")
	defer SDL.FreeSurface(surface)
	texture := SDL.CreateTextureFromSurface(renderer, surface)
	defer SDL.DestroyTexture(texture)

	dst := SDL.Rect{10, 10, 32, 32}
	SDL.RenderCopy(renderer, texture, nil, &dst)

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

destroy :: proc(game: ^State) {
	using game
	SDL.DestroyWindow(window)
	SDL.DestroyRenderer(renderer)
}
