extends Node2D

@onready var wonky: AnimatedSprite2D = $Wonky

func _ready() -> void:
    # La animación se reproduce en loop mientras Wonky está inactivo.
    if wonky.sprite_frames and wonky.sprite_frames.has_animation("pensando"):
        wonky.play("pensando")
