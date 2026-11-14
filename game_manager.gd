extends Node

var portal_connections: Dictionary

@export var levels: Array[PackedScene] = []

func _ready() -> void:
    print("Autoload ready: ", levels)

func start_game() -> void:
    get_tree().change_scene_to_file("res://levels/test_tilemap.tscn");
