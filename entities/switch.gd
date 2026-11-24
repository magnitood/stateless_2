extends Node2D

@export var door:Node2D
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D

func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is Player:
        print("touching switch")
        collision_shape_2d.set_deferred("disabled", true)
        $AnimatedSprite2D.frame = 1
        SoundManager.play_switch()
        await SoundManager.switch.finished
        door.open_thing -= 1
