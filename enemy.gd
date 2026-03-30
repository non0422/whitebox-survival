extends CharacterBody2D


func _on_health_component_died() -> void:
    print("Enemy died")
    queue_free()
