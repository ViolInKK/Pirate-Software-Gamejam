extends Area2D

const PLYAER_PROJECTILE_SPEED: int = 700

var direction: Vector2 = Vector2.ZERO 

func _process(delta: float) -> void:
	pass
	position += direction * PLYAER_PROJECTILE_SPEED * delta
	
func _on_body_entered(body) -> void:
	queue_free()

func _on_despawn_timeout() -> void:
	queue_free()
