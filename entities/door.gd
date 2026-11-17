extends Node2D

var pos:Vector2
var new_pos:Vector2
@export var offset:float

func _ready() -> void:
    pos = global_position
    new_pos = pos + Vector2(0, offset)

func open() -> void:
    print("why aint shit happen")
    var tween:Tween = create_tween()
    
    tween.tween_property(self, "global_position", new_pos, 1.0)
    
