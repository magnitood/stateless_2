extends Node2D

@export var next_level:int


var can_interact:bool = false

func _process(_delta:float) -> void:
    if can_interact == true:
        if Input.is_action_just_pressed("teleport"):
            change_level(next_level)

func change_level(n : int) -> void:
    GameManager.set_level(get_parent().level_no, n)
    


func _on_area_2d_body_entered(body:CharacterBody2D) -> void:
    if body is Player:
        can_interact = true

func _on_area_2d_body_exited(body: CharacterBody2D) -> void:
    if body is Player:
        can_interact = false
