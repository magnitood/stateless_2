extends Sprite2D

@export var flicker_speed: float = 0.06
@export var min_intensity: float = 6
@export var max_intensity: float = 9

var timer: float = 0.0

func _process(delta: float) -> void:
	timer -= delta

	if timer <= 0.0:
		var intensity: float = randf_range(min_intensity, max_intensity)

		modulate = Color(intensity, intensity, intensity, 1.0)
		timer = flicker_speed
