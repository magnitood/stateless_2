extends Node

var portal_connections: Dictionary

var player: CharacterBody2D

const TEST_TILEMAP_ME = preload("res://levels/test_tilemap_me.tscn")
const TEST_LEVEL_2_ME = preload("res://levels/test_level2_me.tscn")

func _ready() -> void:
    pass

func start_game() -> void:
    get_tree().change_scene_to_file("res://levels/test_tilemap.tscn");

func set_level(prev:int, next:int) -> void:
    match next:
        1:
            get_tree().change_scene_to_packed(TEST_TILEMAP_ME)
        2:
            get_tree().change_scene_to_packed(TEST_LEVEL_2_ME)
        _:
            assert(false, "Unreachable")

    await get_tree().scene_changed

    player = get_tree().get_first_node_in_group("player")
    var all_teleporters: Array = get_tree().get_nodes_in_group("level_changer")
    for i:Node2D in all_teleporters:
        if i.next_level == prev:
            player.global_position = i.get_node("teleport").global_position
