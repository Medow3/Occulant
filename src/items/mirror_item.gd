class_name MirrorItem extends Area2D

@export var mirror_pickup_sfx: SFXData

@onready var tilemap: TileMap = get_parent()

func _on_body_entered(body):
	if body is Player:
		SFX.play_sfx(mirror_pickup_sfx)
		tilemap.set_cell(0, tilemap.local_to_map(position), -1)
		GameManager.pickup_mirror()
		queue_free()
