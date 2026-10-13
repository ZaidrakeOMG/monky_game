extends RefCounted
## Optional original backgrounds: pending reattachment by the owner.
## Existing shipped backgrounds remain functional until those files are supplied.

const FALLBACKS := {
	"flappy": "res://assets/backgrounds/flappy_bg.jpg",
	"fruit": "res://assets/backgrounds/fruit_catcher_bg.jpg",
	"jump": "res://assets/backgrounds/jump_bg.jpg",
	"runner": "res://imagenes/runner/cover.png"
}

static func background(game: String) -> Texture2D:
	# Build optional paths so an absent optional asset is not a broken preload.
	var stem: String = "res://assets/backgrounds/" + "wonder_" + game
	for extension in ["png", "jpg", "webp"]:
		var candidate: String = stem + "." + extension
		if ResourceLoader.exists(candidate):
			return load(candidate) as Texture2D
	var fallback: String = str(FALLBACKS.get(game, FALLBACKS["flappy"]))
	return load(fallback) as Texture2D if ResourceLoader.exists(fallback) else null
