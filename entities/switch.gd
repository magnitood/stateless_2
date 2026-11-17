extends Node2D

@export var door:Node2D

func _on_area_2d_body_entered(body:CharacterBody2D) -> void:
	if body.is_in_group("player"):
		print("touching switch")
		door.open()
