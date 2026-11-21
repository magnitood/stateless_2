extends TextureButton

@export var hover_scale := 1.15
@export var hover_rotation := 5.0
@export var duration := 0.18
var power_cards_used := 0
var tween: Tween
var base_scale: Vector2

func _ready()-> void:
    randomize()

    base_scale = scale
    pivot_offset = size / 2

    mouse_entered.connect(_on_hover)
    mouse_exited.connect(_on_unhover)


func _on_hover()-> void:
    SoundManager.play_hover()

    if tween:
        tween.kill()

    # In case the button's scale changed since _ready()

    var target_rotation: float = randf_range(-hover_rotation, hover_rotation)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.parallel().tween_property(
        self,
        "scale",
        base_scale * hover_scale,
        duration
    )

    tween.parallel().tween_property(
        self,
        "rotation_degrees",
        target_rotation,
        duration
    )


func _on_unhover()-> void: 
    
    #$"../unhover".play()

    if tween:
        tween.kill()

    tween = create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_OUT)

    tween.parallel().tween_property(
        self,
        "scale",
        base_scale,
        duration
    )

    tween.parallel().tween_property(
        self,
        "rotation_degrees",
        0.0,
        duration
    )
