@tool
class_name Player
extends CharacterBody2D

@export var speed: float = 500
@export var time_to_get_to_max_acc_sec: float = 0.25

@export var wrap_box: WrapBox

@export var disabled: bool    = false
@export var wrap_player: bool = true

enum GravityDirection {DOWN, UP, LEFT, RIGHT}

var current_gravity_direction: GravityDirection = GravityDirection.DOWN
var default_up_direction: Vector2 = up_direction

@onready var sprite: Sprite2D = $Sprite2D
@onready var foot: Node2D = $PlayerFoot
@onready var default_zoom: Vector2 = $Camera2D.zoom

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

func _physics_process(delta: float) -> void:
    if Engine.is_editor_hint() or disabled:
        update_configuration_warnings()
        return

    rotation = physics_rotation(current_gravity_direction)
    up_direction = default_up_direction.rotated(rotation)

    # TODO: make this log zoom
    var zoom_duration_sec: float = 0.25
    var t: float = delta/zoom_duration_sec
    if Input.is_action_pressed("down"):
        $Camera2D.zoom = $Camera2D.zoom.move_toward(default_zoom - Vector2(1.5, 1.5), t)
    else:
        $Camera2D.zoom = $Camera2D.zoom.move_toward(default_zoom, t)


    # $Camera2D.rotation     = rotation
    # $LeftRayCast.rotation  = rotation
    # $RightRayCast.rotation = rotation
    # $Sprite2D.rotation     = rotation

    var movement: Vector2
    movement.x = Input.get_action_strength("right") - Input.get_action_strength("left")
    movement.y = Input.get_action_strength("jump") if is_on_floor() else 1.5
    if !is_on_floor() and Input.is_action_pressed("down"):
        movement.y *= 1.5

    movement = movement.rotated(physics_rotation(current_gravity_direction))

    # position += movement * delta * speed
    # if we want to split the acceleration and deseleration curves,
    # make if checking movement == 0
    # velocity = velocity.move_toward(movement * speed, speed/time_to_get_to_max_acc_sec * delta)
    velocity = velocity.move_toward(movement * speed, 1600 * delta)

    var rect: Rect2 = wrap_box.get_rect()
    if wrap_player:
        position.x = wrapf(position.x, rect.position.x, rect.position.x + rect.size.x)
        position.y = wrapf(position.y, rect.position.y, rect.position.y + rect.size.y)

    if Input.is_action_just_pressed("interact"):
        current_gravity_direction = get_nearest_wall_gravity()

    move_and_slide()

func get_left_gravity(current: GravityDirection) -> GravityDirection:
    match current:
        GravityDirection.DOWN:
            return GravityDirection.LEFT
        GravityDirection.UP:
            return GravityDirection.RIGHT
        GravityDirection.LEFT:
            return GravityDirection.UP
        GravityDirection.RIGHT:
            return GravityDirection.DOWN
        _:
            assert(false, "Unreachable")
            return GravityDirection.DOWN

func get_right_gravity(current: GravityDirection) -> GravityDirection:
    match current:
        GravityDirection.DOWN:
            return GravityDirection.RIGHT
        GravityDirection.UP:
            return GravityDirection.LEFT
        GravityDirection.LEFT:
            return GravityDirection.DOWN
        GravityDirection.RIGHT:
            return GravityDirection.UP
        _:
            assert(false, "Unreachable")
            return GravityDirection.DOWN

func get_nearest_wall_gravity() -> GravityDirection:
    if $LeftRayCast.is_colliding() and $RightRayCast.is_colliding():
        SoundManager.play_shift()
        var left_point: Vector2 = abs($LeftRayCast.get_collision_point() - position)
        var right_point: Vector2 = abs($RightRayCast.get_collision_point() - position)
        if left_point < right_point:
            return get_left_gravity(current_gravity_direction)
        else:
            return get_right_gravity(current_gravity_direction)
    elif $LeftRayCast.is_colliding():
        SoundManager.play_shift()
        return get_left_gravity(current_gravity_direction)
    elif $RightRayCast.is_colliding():
        SoundManager.play_shift()
        return get_right_gravity(current_gravity_direction)

    return current_gravity_direction

func _get_configuration_warnings() -> PackedStringArray:
    var warnings: PackedStringArray
    if not $Camera2D or not $Camera2D is Camera2D:
        warnings.append("$Camera2D not attached")
    if not wrap_box or not wrap_box is WrapBox:
        warnings.append("Missing Wrap Box")

    if $Camera2D and floor($Camera2D.zoom) != $Camera2D.zoom:
        warnings.append("$Camera2D zoom not integer multiple of resolution, sprites may flicker")
    return warnings
