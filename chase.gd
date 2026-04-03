extends State
class_name Chase

@export var enemy: CharacterBody2D
@export var player: Node2D   # Inspector 里拖 Player 节点
@export var move_speed: float = 200.0
@export var attack_range: float = 50.0

func _enter():
    print("进入 Chase 状态")
    if not player:
        print("没有设置 player,无法追踪")
        return

func _physics_update(_delta: float):
    if not enemy or not player:
        return

    var direction = (player.global_position - enemy.global_position).normalized()
    enemy.velocity = direction * move_speed
    enemy.move_and_slide()

    var dist = enemy.global_position.distance_to(player.global_position)

    if dist > 300:
        print("玩家跑太远，返回 Idle")
        transitioned.emit(self, "idle")

    if dist < attack_range:
        print("玩家进入攻击范围，准备攻击！")
        # 这里可以发信号给大脑，切换到攻击状态
        transitioned.emit(self, "attack")