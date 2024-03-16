package roraima

import SDL "vendor:sdl2"

CollisionEvent :: struct {
	a: ^Entity,
	b: ^Entity,
}

KeyPressedEvent :: struct {
	symbol: SDL.Keycode,
}

EventKind :: enum {
	Collision,
	KeyPressed,
}

EventData :: union {
	CollisionEvent,
	KeyPressedEvent,
}

Event :: struct {
	kind: EventKind,
	data: EventData,
}

EventCallback :: struct {
	execute: proc(data: EventData),
}

Handlers :: [dynamic]^EventCallback

EventBus :: struct {
	subscribers: map[EventKind]Handlers,
}

new_event_bus :: proc() -> (bus: ^EventBus) {
	subscribers := make(map[EventKind]Handlers)
	bus = new(EventBus)
	bus.subscribers = subscribers

	return
}

delete_event_bus :: proc(bus: ^EventBus) {
	delete(bus.subscribers)
	free(bus)

	return
}

reset_event_bus :: proc(bus: ^EventBus) {
	clear(&bus.subscribers)
}

subscribe_to_event :: proc(
	bus: ^EventBus,
	event_kind: EventKind,
	callback: proc(event: EventData),
) {
	if ok := event_kind in bus.subscribers; !ok {
		new_handlers := make(Handlers)
		bus.subscribers[event_kind] = new_handlers
	}
	subscriber := new(EventCallback)
	subscriber.execute = callback

	append(&bus.subscribers[event_kind], subscriber)
}

emit_event :: proc(bus: ^EventBus, event: Event) {
	handlers, ok := bus.subscribers[event.kind];if ok {
		debug("emit_event: handlers len (%v)", len(handlers))
		for handler in handlers {
			handler.execute(event.data)
		}
	}
}
