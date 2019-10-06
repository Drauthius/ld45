extends "res://src/InteractableObject.gd"

func interact():
	$Sprite.frame = 1
	remove_from_group("Interactable")
	set_outline(false)