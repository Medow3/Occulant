class_name MirrorItem extends Area2D



func _on_body_entered(body):
	if body is Player:
		GameManager.pickup_mirror()
		queue_free()
