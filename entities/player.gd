@tool
class_name Player
extends CharacterBody2D

enum GravityDirection {DOWN, UP, LEFT, RIGHT}

@export var speed: float
@export var camera: Camera2D

@export var wrap_box: WrapBox
        
var current_gravity_direction: GravityDirection = GravityDirection.DOWN
    
func physics_rotation(dir: GravityDirection) -> float:
    match dir:
        GravityDirection.DOWN:
            return 0
        GravityDirection.UP:
            return PI
        GravityDirection.LEFT:
            return PI/2
        GravityDirection.RIGHT:
            return -PI/2
        _:
            assert(false, "Unreachable")
            return 0

func _ready() -> void:
    camera.ignore_rotation = false
    camera.rotation_smoothing_enabled = true
    camera.rotation_smoothing_speed = 10
        
func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint():
        update_configuration_warnings()
        return

    camera.rotation = physics_rotation(current_gravity_direction)
    
    var movement: Vector2
    movement.x = Input.get_action_strength("right") - Input.get_action_strength("left")
    movement.y = Input.get_action_strength("down") - Input.get_action_strength("up")
    movement = movement.normalized().rotated(physics_rotation(current_gravity_direction))

    position += movement * delta * speed
    
    var rect: Rect2 = wrap_box.get_rect()
    position.x = wrapf(position.x, rect.position.x, rect.position.x + rect.size.x)
    position.y = wrapf(position.y, rect.position.y, rect.position.y + rect.size.y) 

    if Input.is_action_just_pressed("interact"):
        match current_gravity_direction:
            GravityDirection.DOWN:
                current_gravity_direction = GravityDirection.LEFT
            GravityDirection.UP:
                current_gravity_direction = GravityDirection.RIGHT
            GravityDirection.LEFT:
                current_gravity_direction = GravityDirection.UP
            GravityDirection.RIGHT:
                current_gravity_direction = GravityDirection.DOWN
    
    move_and_slide()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray
    if not camera or not camera is Camera2D:
        warnings.append("Camera not attached")
    if not wrap_box or not wrap_box is WrapBox:
        warnings.append("Missing Wrap Box")
    if floor(camera.zoom) != camera.zoom:
        warnings.append("Camera zoom not integer multiple of resolution, sprites may flicker")
    return warnings
