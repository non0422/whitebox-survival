extends CharacterBody2D

#实例话一个子弹场景

var bullet_scene = preload("res://bullet.tscn")

const SPEED = 300
#移动
func _physics_process(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
	look_at(get_global_mouse_position())



func _input(event):
	if event.is_action_pressed("shoot"):
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	#设置子弹位置为玩家位置加上一个偏移，使其从玩家前方发出
	var forward = Vector2.RIGHT.rotated(rotation)
	var offset_distance = 40
	bullet.global_position = global_position + forward * offset_distance
	
	#设置子弹方向为玩家朝向
	bullet.direction = forward
	
	#设置子弹的射手为玩家
	bullet.shooter = self

	#将子弹添加到场景树中
	get_tree().current_scene.add_child(bullet)

func take_damage(damage: int) -> void:
	# 这里的路径用你刚才找对的那个真实路径
	var health_component = $HealthComponent 
	
	if health_component != null and health_component.has_method("take_damage"):
		health_component.take_damage(damage)



func _on_health_component_died() -> void:
	print("Player died")
	queue_free()
