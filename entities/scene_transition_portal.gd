@tool
class_name SceneTransitionPortal
extends StaticBody2D

@export_file("*.tscn") var scene_to_transition_to_path: String
@export var distance: float
@export var player: Player

@export_custom(PROPERTY_HINT_NONE, "", PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY)
var portal_id: int = 0
@export var to_portal_id: int = 0

var PORTAL_COUNTER_FILE_PATH: String = "res://portal_counter.cfg"
var player_in_view_region: bool = false

var viewport: SubViewport
@onready var camera: Camera2D = $Camera2D
@onready var polygon: Polygon2D = $Polygon2D

var next_scene: Level
@onready var thread: Thread = Thread.new()
var thread_started: bool = false

@export var flip_x: bool = false
@export var flip_y: bool = false

func _ready() -> void:
    if Engine.is_editor_hint():
        if self == get_tree().edited_scene_root:
            return

        if portal_id == 0:
            portal_id = _generate_portal_id()
            notify_property_list_changed()
        return

    if flip_x:
        $Sprite2D.scale.x = -1
        $CollisionPolygon2D.scale.x = -1
        $CollisionDisableRegion.scale.x = -1
        $TeleportRegion.scale.x = -1

    if flip_y:
        $Sprite2D.scale.y = -1
        $CollisionPolygon2D.scale.y = -1
        $CollisionDisableRegion.scale.y = -1
        $TeleportRegion.scale.y = -1

    viewport = SubViewport.new()
    viewport.size = get_viewport_rect().size
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
    viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

    add_child.call_deferred(viewport)

    process_physics_priority = 100

    assert(portal_id != 0)


func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    update_polygon_shape()


func update_polygon_shape() -> void:
    if player:
        var poly: PackedVector2Array = $Polygon2D.polygon

        var local_foot: Vector2 = to_local(player.foot.global_position)
        var pt: Vector2 = $Top.position - local_foot
        var pb: Vector2 = $Bottom.position - local_foot

        var d: float = distance if flip_x else -distance

        poly[0] = $Top.position
        poly[1] = $Top.position + (pt * (d / pt.x) if not is_zero_approx(pt.x) else Vector2(d, 0.0))
        poly[2] = $Bottom.position + (pb * (d / pb.x) if not is_zero_approx(pb.x) else Vector2(d, 0.0))
        poly[3] = $Bottom.position
        $Polygon2D.polygon = poly


func _physics_process(_delta: float) -> void:
    assert($Camera2D.zoom.x == $Camera2D.zoom.y)
    if Engine.is_editor_hint():
        update_configuration_warnings()
        return

    if player_in_view_region:
        if thread_started:
            thread.wait_to_finish()
            thread_started = false
        $Polygon2D.visible = true
    else:
        $Polygon2D.visible = false

    if player and next_scene and _is_player_touching_teleport_region():
        _teleport_player()

func _is_player_touching_teleport_region() -> bool:
    var portal_collision_shape: CollisionShape2D = $TeleportRegion/CollisionShape2D
    var teleport_collider_shape: CollisionShape2D = player.teleport_collider

    if portal_collision_shape.shape.collide(
        portal_collision_shape.global_transform,
        teleport_collider_shape.shape,
        teleport_collider_shape.global_transform
    ):
        return true

    return false

func _teleport_player() -> void:
    if thread_started:
        thread.wait_to_finish()
        thread_started = false

    var p: Player = player
    var offset: Vector2 = player.position - position
    var portal: SceneTransitionPortal = next_scene.get_portal(to_portal_id)
    portal.collision_layer = 1 << 1

    player = null

    var from_scene: Level = get_parent()
    var root: Node = from_scene.get_parent()
    portal.next_scene = from_scene

    viewport.remove_child(next_scene)
    root.remove_child(from_scene)
    root.add_child(next_scene)

    next_scene.move_player_to_level(p, portal.position + offset)

    p.camera.make_current()
    # camera.make_current()
    portal.viewport.add_child(from_scene)

    portal.player = p

    portal.player_in_view_region = true
    portal.polygon.visible = true
    portal.update_polygon_shape()
    portal.refresh_polygon()

func _generate_portal_id() -> int:
    var config: ConfigFile = ConfigFile.new()
    var id: int

    if config.load(PORTAL_COUNTER_FILE_PATH) == OK:
        id = config.get_value("counter", "next_id")

    config.set_value("counter", "next_id", id+1)
    if config.save(PORTAL_COUNTER_FILE_PATH) != OK:
        print("Catastrophic failure to save")

    return id

func _on_view_activation_region_body_entered(body: Node2D) -> void:
    if body is Player:
        player_in_view_region = true

func _on_view_activation_region_body_exited(body: Node2D) -> void:
    if body is Player:
        player_in_view_region = false

func load_and_instantiate_next_scene() -> void:
    var scene: PackedScene = ResourceLoader.load(scene_to_transition_to_path)
    if scene == null:
        push_error("Failed to instantiate scene")
        return

    next_scene = scene.instantiate()

    var lambda: Callable = func() -> void:
        viewport.add_child(next_scene) # the _ready() function of the scene is called here
        var to_portal: SceneTransitionPortal = next_scene.get_portal(to_portal_id)
        to_portal.camera.make_current()
        to_portal.next_scene = get_parent()

        refresh_polygon()
        # viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
        # viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
        # var viewport_texture: Texture2D = viewport.get_texture()
        # $Polygon2D.texture = viewport_texture
        # $Polygon2D.texture_offset = viewport_texture.get_size()*0.5 / $Camera2D.zoom
        # $Polygon2D.texture_scale = $Camera2D.zoom

    lambda.call_deferred()

    print("Scene Loaded")

func _on_load_scene_region_body_entered(body: Node2D) -> void:
    if body is Player and next_scene == null and not thread_started:
        var err: Error = thread.start(load_and_instantiate_next_scene)
        if err != Error.OK:
            print("Error occured while starting thread: %s" % err)
        thread_started = true

func _on_collision_disable_region_body_entered(body: Node2D) -> void:
    if body is Player:
        collision_layer = 1 << 1


func _on_collision_disable_region_body_exited(body: Node2D) -> void:
    if body is Player:
        collision_layer = 1

# func _on_teleport_region_area_entered(area: Area2D) -> void:
#     assert(next_scene != null)
#     if area.get_parent() is Player and player:
#         var p: Player = player;
#         var offset: Vector2 = player.position-position
#         var portal: SceneTransitionPortal = next_scene.get_portal(to_portal_id)
#         portal.collision_layer = 1 << 1
# 
#         player = null
# 
#         var labmda: Callable = func() -> void:
#             var from_scene: Level = get_parent()
#             var root: Node = from_scene.get_parent()
#             portal.next_scene = from_scene
# 
#             viewport.remove_child(next_scene)
#             root.remove_child(from_scene)
#             root.add_child(next_scene)
# 
#             next_scene.move_player_to_level(p, portal.position+offset)
# 
#             p.camera.make_current()
#             portal.viewport.add_child(from_scene)
# 
#             # portal.player.camera.make_current()
# 
#             portal.player = p
#             portal.player_in_view_region = true
#             portal.polygon.visible = true
#             portal.update_polygon_shape()
#             portal.refresh_polygon()
# 
#         labmda.call_deferred()
# 
#         # portal.next_scene = get_parent()
#         # next_scene.move_player_to_level(player, Vector2(0, 0))
#         # portal.player = player
#         # viewport.remove_child(next_scene)
#         # get_tree().change_scene_to_node(next_scene)
#         # portal.camera.make_current()

func refresh_polygon() -> void:
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
    viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

    var viewport_texture: Texture2D = viewport.get_texture()

    $Polygon2D.texture = viewport_texture
    $Polygon2D.texture_offset = viewport_texture.get_size()*0.5 / $Camera2D.zoom
    $Polygon2D.texture_scale = $Camera2D.zoom

    # viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
    # viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
    # var viewport_texture: Texture2D = viewport.get_texture()
    # $Polygon2D.texture = viewport_texture
    # $Polygon2D.texture_offset = viewport_texture.get_size()*0.5 / $Camera2D.zoom

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray
    if not player:
        warnings.append("Missing player")
    if not scene_to_transition_to_path:
        warnings.append("Missing scene to transition to")
    if not camera:
        warnings.append("Missing Camera")
    if to_portal_id == 0:
        warnings.append("To portal id is 0")

    return warnings
