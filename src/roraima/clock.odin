package roraima

import SDL "vendor:sdl2"

Timeout :: struct {
	lifespan: u32,
}

new_timeout :: proc(lifespan: f64) -> (timeout: ^Timeout, err: Error) {
	timeout = new(Timeout) or_return
	now := SDL.GetTicks()
	lifespan_in_seconds := u32(lifespan * SECOND)
	timeout.lifespan = now + lifespan_in_seconds
	inform("new_timeout: %v", timeout.lifespan - now)
	return
}

change_box_color_timeout :: proc(entity: ^Entity) {
	collider := get_box_collider(entity)
	collider.color = GAME_COLORS[.Yellow]
	if collider.timeout != nil {
		free(collider.timeout)
		collider.timeout = nil
	}
	inform("change_box_color_timeout: %v", entity.id)
	timeout, err := new_timeout(0.2)
	catch(err, "failed to initiate timeout")
	collider.timeout = timeout
}

set_timeout :: proc(entity: ^Entity, callback: proc(entity: ^Entity)) {
	callback(entity)
}

clear_change_box_color_timeout :: proc(collider: ^BoxCollider) {
	if collider.timeout == nil {return}

	now := SDL.GetTicks()
	is_dead := now > collider.timeout.lifespan
	if is_dead {
		collider.color = GAME_COLORS[.Red]
		free(collider.timeout)
		collider.timeout = nil
	}
}

clear_collider_timeouts :: proc(collider: ^BoxCollider) {
	clear_change_box_color_timeout(collider)
}

clear_timeouts :: proc {
	clear_collider_timeouts,
}
