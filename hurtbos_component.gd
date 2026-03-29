extends Area2D
class_name HurtboxComponent

@export var health_component: HealthComponent

func take_damage(damage: int) -> void:
    if health_component != null:
        health_component.take_damage(damage)