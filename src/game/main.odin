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
	catch(err, "could not create logger")
	context.logger = logger^

	game, err = new_game()
	catch(err, "could not create game")

	init_game(game)
	run_game(game, INIT_ALL_SYSTEMS, setup)

	defer destroy_game(game)
}
