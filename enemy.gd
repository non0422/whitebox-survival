extends CharacterBody2D


func _on_health_component_died() -> void:
    print("Enemy died")
    queue_free()

# 拿到你的图形节点（根据你实际的名字来，比如 $ColorRect 或 $Sprite2D）
@onready var visual_node = $ColorRect 

# 这是连接健康组件 damaged 信号自动生成的函数
func _on_health_component_damaged() -> void:
    var mat = visual_node.material
    
    if mat is ShaderMaterial:
        # 1. 瞬间纯白（打击爆发点）
        mat.set_shader_parameter("flash_modifier", 1.0)
        
        # 2. 杀掉旧的动画（防呆设计）：如果玩家拿冲锋枪一秒打10发，防止上一个变黑的动画覆盖当前的变白动画
        var tween = create_tween()
        
        # 3. 核心打击感魔法：让纯白在怪物身上“定格” 0.05 秒，强行让玩家的视网膜捕捉到这个瞬间！
        tween.tween_interval(1) 
        
        # 4. 曲线褪色：在 0.2 秒内变回原色，并加上指数级缓动（一开始褪色慢，后面褪色快，有种“弹簧”的拖尾感）
        tween.tween_property(mat, "shader_parameter/flash_modifier", 0.0, 0.2)\
            .set_trans(Tween.TRANS_EXPO)\
            .set_ease(Tween.EASE_OUT)


