class_name Level
extends Node2D

@export var wrap_box: WrapBox
@export var level_no: int

func get_portal(id: int) -> SceneTransitionPortal:
    for c: Node in get_children():
        if c is SceneTransitionPortal and c.portal_id == id:
            return c
    return null

func move_player_to_level(player: Player, pos: Vector2) -> void:
    for child: Node in get_children():
        if child is SceneTransitionPortal:
            child.player = player

    player.owner = null
    player.reparent(self, false)
    player.position = pos
    # wrap_box.boundary_crossers.append(player)
    # wrap_box.array_of_sprite_list.append()
    player.wrap_box = wrap_box
