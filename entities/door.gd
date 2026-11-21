extends Node2D

enum dir{horizontal, vertical}

var pos:Vector2
var new_pos:Vector2
@export var offset:float
@export var open_thing:int
@export var move_dir:dir
@export var delay:float = 0.2
var can_open:bool = true

func _ready() -> void:
	pos = global_position
	if move_dir == dir.vertical:
		new_pos = pos + Vector2(0, offset)
	elif move_dir == dir.horizontal:
		new_pos = pos + Vector2(offset, 0)
	
	
func _process(delta: float) -> void:
	print(open_thing)
	if can_open:
		if open_thing <= 0:
			delay -= delta
			if delay <= 0.0:
				open()
	else:
		pass

func open() -> void:
	print("why aint shit happen")
	can_open = false
	
	SoundManager.play_door()
	
	var tween:Tween = create_tween()
	
	tween.tween_property(self, "global_position", new_pos, 1.0)
	
