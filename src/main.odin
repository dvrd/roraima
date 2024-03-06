package roraima

import "core:fmt"
import "core:log"
import "core:os"

main :: proc() {
	context.logger = create_logger()

	inform("Initializing game enginre 'Roraima v1.0.0'")

	registry := new(Registry)
	game := new(State)
	game.registry = registry
	initialize(game)
	run(game)
	defer destroy_game(game)
}
