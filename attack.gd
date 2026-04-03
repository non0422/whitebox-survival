extends State
class_name Attack

@export var enemy: CharacterBody2D
@export var player: Node2D   # Inspector 里拖 Player 节点
@export var attack_duration: float = 0.5
@export var knockback_force: float = 100.0

var has_attacked: bool = false
var attack_timer: float = 0.0

func _enter():
    print("进入 Attack 状态")
    has_attacked = false
    attack_timer = 0.0

    if player and enemy:
        var direction = (player.global_position - enemy.global_position).normalized()
        enemy.velocity = direction * knockback_force  

        if player.has_method("take_damage"):
            player.call("take_damage", 10)  # 假设伤害值为 10
        has_attacked = true

func _physics_update(_delta: float):
    enemy.move_and_slide()

    attack_timer += _delta

    if has_attacked and attack_timer >= attack_duration:
        print("攻击结束，返回 Chase")
        transitioned.emit(self, "chase")