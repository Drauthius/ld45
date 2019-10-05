extends Node2D

func _ready():
	$Sprite.material = $Sprite.material.duplicate()

func set_outline(enabled):
	$Sprite.material.set_shader_param("enabled", enabled)