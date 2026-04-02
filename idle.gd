extends State
class_name Idle

@export var enemy:CharacterBody2D
@export var player:CollisionShape2D
@export var move_speed:float = 30.0

var move_direction:Vector2
var wander_timer:float

func randomize_wander_timer() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_timer = randf_range(1.0, 3.0)

func _enter() -> void:
	randomize_wander_timer()
	print("随机漫游状态进入")


# 在 physics_update 中加入检测逻辑
func _physics_update(_delta: float):
	# ... 原有的游走逻辑 ...
	if wander_timer > 0:
		wander_timer -= _delta
		enemy.velocity = move_direction * move_speed
		enemy.move_and_slide()
	else:
		randomize_wander_timer()

	# 新增：检测玩家
	if player:
		var dist = enemy.global_position.distance_to(player.global_position)
		if dist < 150: # 如果玩家进入警戒线
			print("发现玩家，准备追击！")
			transitioned.emit(self, "chase") # 发信号给大脑：我要追人！
