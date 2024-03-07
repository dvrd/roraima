package roraima

import "core:fmt"
import "core:log"
import "core:os"

main :: proc() {
	context.logger = create_logger()
	game := new_game()
	initialize(game)
	run(game)
	defer destroy_game(game)
}
