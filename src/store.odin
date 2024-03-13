package roraima

import "core:os"
import "core:strings"
import SDL "vendor:sdl2"
import "vendor:sdl2/image"

AssetStore :: distinct map[string]^SDL.Texture

new_asset_store :: proc() -> ^AssetStore {
	store, err := new(AssetStore)
	if err != nil {
		error(
			"%vnew_asset_store:%v Error creating new AssetStore: %v",
			PURPLE,
			END,
			err,
		)
		os.exit(1)
	}
	inform("%vnew_asset_store:%v Created new AssetStore: %v", PURPLE, END, store)
	return store
}

delete_asset_store :: proc(store: ^AssetStore) {
	inform("%vdelete_asset_store:%v Deleting AssetStore", PURPLE, END)
	free(store)
}

clear_assets :: proc(store: ^AssetStore) {
	for _, texture in store {
		SDL.DestroyTexture(texture)
	}
	clear(store)
}

add_texture :: proc(
	store: ^AssetStore,
	renderer: ^SDL.Renderer,
	asset_id: string,
	file_path: string,
) {
	surface := image.Load(strings.clone_to_cstring(file_path))
	defer SDL.FreeSurface(surface)
	texture := SDL.CreateTextureFromSurface(renderer, surface)
	store[asset_id] = texture
}
