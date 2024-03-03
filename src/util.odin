package roraima

wait :: proc(target: u32) {
	for !SDL.TICKS_PASSED(SDL.GetTicks(), target) {}
}
