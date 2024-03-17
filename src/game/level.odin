package game

import "core:os"
import "src:roraima"

setup_level :: proc(game: ^roraima.State) {
	using game
	using roraima

	add_texture(
		asset_store,
		renderer,
		"tilemap-image",
		"assets/tilemaps/jungle.png",
	)

	tile_size: int = 32
	tile_scale := 2.
	map_n_cols := 29
	map_n_rows := 20
	next := 0
	ch: byte
	data, ok := os.read_entire_file("assets/tilemaps/jungle.map")
	if !ok {
		error("could not open tilemap file.")
		os.exit(1)
	}

	for y := 0; y < map_n_rows; y += 1 {
		for x := 0; x < map_n_cols; x += 1 {
			ch = data[next]
			next += 1
			srcRectY := int(ch - '0') * tile_size
			ch = data[next]
			next += 2
			srcRectX := int(ch - '0') * tile_size
			tile := create_entity(registry)
			group(tile, "tiles")
			posX := cast(f64)x * cast(f64)tile_size * tile_scale
			posY := cast(f64)y * cast(f64)tile_size * tile_scale
			position := Vec2{posX, posY}
			scale := Vec2{tile_scale, tile_scale}
			add_component(tile, new_transform(position, scale, 0))
			add_component(
				tile,
				new_sprite(
					"tilemap-image",
					cast(i32)tile_size,
					cast(i32)tile_size,
					cast(i32)srcRectX,
					cast(i32)srcRectY,
				),
			)
		}
	}
	level_map = {
		x = 0,
		y = 0,
		w = i32(map_n_cols * tile_size * cast(int)tile_scale),
		h = i32(map_n_rows * tile_size * cast(int)tile_scale),
	}
}
