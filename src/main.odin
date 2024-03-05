package roraima

import "core:fmt"
import "core:log"
import "core:os"

main :: proc() {
	context.logger = create_logger()

	inform("Initializing game enginre 'Roraima v1.0.0'")

	game := new(State)
	initialize(game)
	run(game)
	defer destroy(game)
}
