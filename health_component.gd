extends Node
class_name HealthComponent

signal died 
signal damaged

@export var max_health: int = 100
var current_health: int = max_health

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health -= amount
    print("Took damage: ", amount, " Current health: ", current_health)
    damaged.emit()
    if current_health <= 0:
        died.emit()