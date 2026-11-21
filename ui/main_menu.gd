extends Control

@onready var Fade: AnimationPlayer = $Fade


func _on_button_2_pressed() -> void:
	$hover3.play()
	
	

func _on_button_pressed() -> void:
	$hover3.play()
	$ColorRect2.show()
	Fade.play("fade_in")
	await Fade.animation_finished
	Fade.play_backwards("fade_in")
	await Fade.animation_finished
	GameManager.start_game()
	$ColorRect2.hide()
