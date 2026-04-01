extends State
class_name Idle

@export var enemy:CharacterBody2D
@export var move_speed:float = 10.0

var move_direction:Vector2
var wander_timer:float

func randomize_wander_timer() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_timer = randf_range(1.0, 3.0)

func _enter() -> void:
	randomize_wander_timer()
	print("随机漫游状态进入")

func _physics_process(_delta: float) -> void:
	if wander_timer > 0:
		wander_timer -= _delta
		enemy.velocity = move_direction * move_speed
		enemy.move_and_slide()
	else:
		randomize_wander_timer()
