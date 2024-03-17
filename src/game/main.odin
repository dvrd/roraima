package game

import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "src:roraima"

setup :: proc(game: ^roraima.State) {
	using game
	using roraima

	setup_player(game)
	setup_tank(game)
	setup_truck(game)
	setup_radar(game)
	roraima.inform("Setting up level")
	setup_level(game)
	roraima.inform("Level set up")
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
