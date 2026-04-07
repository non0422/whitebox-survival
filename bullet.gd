extends Area2D

var direction = Vector2.RIGHT
var speed = 600
var damage = 10
var shooter = null

func _physics_process(delta):
    position += direction * speed * delta

func _on_body_entered(_body):
    if _body == shooter:
        return
    queue_free()


func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
    queue_free()    
	
