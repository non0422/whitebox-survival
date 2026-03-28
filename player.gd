extends CharacterBody2D

#实例话一个子弹场景

@onready var bullet_scene = preload("res://bullet.tscn")

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
	#设置子弹位置为枪口位置
	bullet.global_position = position
	#设置子弹方向为玩家朝向
	bullet.direction = Vector2.RIGHT.rotated(rotation)
	#将子弹添加到场景树中
	get_tree().current_scene.add_child(bullet)
	
