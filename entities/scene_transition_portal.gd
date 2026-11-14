@tool
class_name SceneTransitionPortal
extends Node2D

@export var scene_to_transition_to: PackedScene

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var portal_id: int = 0

var PORTAL_COUNTER_FILE_PATH: String = "res://portal_counter.cfg"

func _ready() -> void:
    if Engine.is_editor_hint():
        if self == get_tree().edited_scene_root:
            return

        if portal_id == 0:
            portal_id = _generate_portal_id()
            notify_property_list_changed()

    assert(portal_id != 0)


func _physics_process(_delta: float) -> void:
    if self == get_tree().edited_scene_root:
        return

    assert(portal_id != 0)


func _generate_portal_id() -> int:
    var config: ConfigFile = ConfigFile.new()
    var id: int

    if config.load(PORTAL_COUNTER_FILE_PATH) == OK:
        id = config.get_value("counter", "next_id")

    config.set_value("counter", "next_id", id+1)
    if config.save(PORTAL_COUNTER_FILE_PATH) != OK:
        print("Catastrophic failure to save")

    return id
