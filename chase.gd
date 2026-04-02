extends State
class_name Chase

@export var enemy: CharacterBody2D
@export var move_speed: float = 200.0
@export var player: Node2D   # Inspector 里拖 Player 节点

var player_root: Node2D       # 用来计算 global_position

func _enter():
    print("进入 Chase 状态")

    if player:
        player_root = player  # 直接用 Inspector 拖的 Player 节点
        print("player 已赋值，player_root:", player_root)
    else:
        print("player 为空！请检查赋值")

func _physics_update(_delta: float):
    if not enemy or not player_root:
        return

    var direction = (player_root.global_position - enemy.global_position).normalized()
    enemy.velocity = direction * move_speed
    enemy.move_and_slide()

    var dist = enemy.global_position.distance_to(player_root.global_position)
    if dist > 300:
        print("玩家跑太远，返回 Idle")
        transitioned.emit(self, "idle")