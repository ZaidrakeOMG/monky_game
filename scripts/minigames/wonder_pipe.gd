extends RefCounted
## Replaces only the visual and refines the collider to follow its rim/body.
## Texture is a cropped and optimized version of the owner's supplied PNG.

const PIPE: Texture2D = preload("res://assets/ui/wonder/pipe_green.png")
const CAP_SOURCE_HEIGHT: int = 48

static func dress(pair: Node2D) -> void:
	for area in pair.get_children():
		if not area is Area2D or not area.has_meta("obstacle"):
			continue
		var old: ColorRect = null
		var collider: CollisionShape2D = null
		for child in area.get_children():
			if child is ColorRect:
				old = child
			elif child is CollisionShape2D:
				collider = child
		if old == null or collider == null:
			continue
		var dimensions: Vector2 = old.size
		var start: Vector2 = old.position
		var is_top: bool = is_zero_approx(start.y)
		var cap_height: float = minf(float(CAP_SOURCE_HEIGHT), dimensions.y - 1.0)
		var art := NinePatchRect.new()
		art.name = "GreenPipeArt"
		art.texture = PIPE
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		art.patch_margin_top = CAP_SOURCE_HEIGHT
		art.patch_margin_bottom = 9
		art.size = dimensions
		art.position = start
		if is_top:
			art.position.y += dimensions.y
			art.scale.y = -1.0
		area.add_child(art)
		area.remove_child(old)
		old.queue_free()
		var body := RectangleShape2D.new()
		body.size = Vector2(dimensions.x * 0.84, dimensions.y - cap_height)
		collider.shape = body
		collider.position = Vector2(0, start.y + body.size.y / 2.0 + (0.0 if is_top else cap_height))
		var rim := CollisionShape2D.new()
		rim.name = "RimCollision"
		var rim_shape := RectangleShape2D.new()
		rim_shape.size = Vector2(dimensions.x, cap_height)
		rim.shape = rim_shape
		rim.position = Vector2(0, start.y + (dimensions.y - cap_height / 2.0 if is_top else cap_height / 2.0))
		area.add_child(rim)
