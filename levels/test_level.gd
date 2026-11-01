extends Node2D

func _on_tp_into_box_area_entered(body: Node2D) -> void:
    if body is Player:
        $Player.position = $BoxSpawnPoint.position

func _on_tp_outof_box_area_entered(body: Node2D) -> void:
    if body is Player:
        $Player.position = $OutsideSpawnPoint.position
