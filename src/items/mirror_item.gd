class_name MirrorItem extends Area2D

@onready var tilemap: TileMap = get_parent()

func _on_body_entered(body):
	if body is Player:
		GameManager.pickup_mirror()
		tilemap.set_cell(0, tilemap.local_to_map(position), -1)
		queue_free()
