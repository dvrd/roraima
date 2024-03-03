package roraima

import "core:fmt"

main :: proc() {
	game := new(State)
	initialize(game)
	run(game)
	defer destroy(game)
}
