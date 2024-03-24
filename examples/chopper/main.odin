package game

import "core:fmt"
import "core:log"
import "core:os"
import "src:roraima"

setup :: proc(game: ^roraima.State) {
	using game
	using roraima

	add_texture(
		asset_store,
		renderer,
		"bullet-image",
		"assets/images/bullet.png",
	)

	setup_radar(game)
	setup_player(game)
	setup_tank(game)
	setup_truck(game)
	setup_level(game)
}

main :: proc() {
	using roraima
	game: ^State
	logger: ^log.Logger
	err: Error

	logger, err = create_logger()
	handle_err(err, "main: could not create logger %v")
	context.logger = logger^

	game, err = new_game()
	handle_err(err, "main: could not create game %v")

	init_game(game)
	run_game(game, INIT_ALL_SYSTEMS, setup)

	defer destroy_game(game)
}
