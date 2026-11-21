extends Node2D

@onready var select: AudioStreamPlayer = $select
@onready var switch: AudioStreamPlayer = $switch
@onready var door: AudioStreamPlayer = $door

func _ready() -> void:
    pass

func stop_menu() -> void:
    $menu.stop()

func play_shift() -> void:
    $shift.play()
    
func play_hover() -> void:
    $hover.play()

func play_select() -> void:
    $select.play()

func play_switch() -> void:
    $switch.play()

func play_door() -> void:
    $door.play()
