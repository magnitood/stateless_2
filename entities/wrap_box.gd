@tool
class_name WrapBox
extends Area2D

@export var boundary_crossers: Array[Node2D] = []
@export var disable_mirroring: bool = false

var array_of_sprite_list: Array[Array] = []

var offsets: Array[Vector2] = [
    Vector2( 0, -1),
    Vector2(-1, -1),
    Vector2( 1, -1),
    Vector2( 0,  1),
    Vector2(-1,  1),
    Vector2( 1,  1),
    Vector2(-1,  0),
    Vector2( 1,  0)
]

func _ready() -> void:
    assert(get_parent() is CanvasItem)
    if Engine.is_editor_hint() or disable_mirroring:
        return
        
    var rect: Rect2 = get_rect()
    var viewport: SubViewport = SubViewport.new()
    var camera: Camera2D = Camera2D.new()
    camera.zoom = get_viewport().get_camera_2d().zoom
    
    viewport.add_child(camera)
    viewport.size = rect.size * get_viewport().get_camera_2d().zoom
    viewport.world_2d = get_parent().get_world_2d()
    viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    viewport.canvas_item_default_texture_repeat = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_REPEAT_ENABLED

    var viewport_texture: Texture2D = viewport.get_texture()

    get_parent().add_child.call_deferred(viewport)
    for offset in offsets:
        get_parent().add_child.call_deferred(make_sprite(position + offset*rect.size, viewport_texture))

    for bc in boundary_crossers:
        var detected_sprite: Sprite2D
        for child in bc.get_children():
            if child is Sprite2D:
                detected_sprite = child
                break

        var sprites: Array[Sprite2D] = []
        for offset in offsets:
            var new_sprite: Sprite2D = detected_sprite.duplicate()
            get_parent().add_child.call_deferred(new_sprite)
            sprites.append(new_sprite)
        array_of_sprite_list.append(sprites)


func _process(_delta: float) -> void:
    scale.x = -scale.x if scale.x < 0 else scale.x
    scale.y = -scale.y if scale.y < 0 else scale.y
    scale = floor(scale)
    
    if Engine.is_editor_hint() or disable_mirroring:
        return

    assert(boundary_crossers.size() == array_of_sprite_list.size())
    for i in array_of_sprite_list.size():
        var sprite_list: Array[Sprite2D] = array_of_sprite_list[i]
        for j in offsets.size():
            sprite_list[j].position = boundary_crossers[i].position + offsets[j]*get_rect().size



func get_rect() -> Rect2:
    var rect: Rect2 = Rect2()
    rect.position = Vector2(position - scale/2)
    rect.size = scale
    return rect

func make_sprite(
    pos: Vector2,
    texture: Texture2D
) -> Sprite2D:
    var sprite: Sprite2D = Sprite2D.new()
    sprite.position = pos
    sprite.texture = texture
    sprite.scale /= get_viewport().get_camera_2d().zoom
    return sprite
