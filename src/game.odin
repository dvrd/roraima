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
	player:        struct {
		pos: Vec2,
		vel: Vec2,
	},
	clock:         struct {
		delta:       f32,
		delta_ms:    u32,
		last_frame:  u32,
		last_second: i64,
		fps:         u32,
		frames:      u32,
	},
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

	player = {
		pos = {10, 20},
		vel = {100, 0},
	}

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

	player.pos += player.vel * clock.delta

	clock.last_frame = SDL.GetTicks()
}

render :: proc(game: ^State) {
	using game

	SDL.SetRenderDrawColor(renderer, 21, 21, 21, 255)
	SDL.RenderClear(renderer)

	// Draw a PNG texture
	surface := image.Load("./assets/images/tank-tiger-right.png")
	defer SDL.FreeSurface(surface)
	texture := SDL.CreateTextureFromSurface(renderer, surface)
	defer SDL.DestroyTexture(texture)

	sprite_res: i32 = 64
	dst := SDL.Rect {
		cast(i32)player.pos.x,
		cast(i32)player.pos.y,
		sprite_res,
		sprite_res,
	}
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
	SDL.Quit()
}
