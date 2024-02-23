class_name MirrorItem extends Area2D

@export var mirror_pickup_sfx: SFXData

@onready var tilemap: TileMap = get_parent()
# This timer fixes a bug where you could collect an extra mirror if you undo
# while standing on a place where a mirror was.
@onready var timer: Timer = $Timer 


func _on_body_entered(body):
	if body is Player and timer.is_stopped():
		print("pickup")
		SFX.play_sfx(mirror_pickup_sfx)
		tilemap.set_cell(0, tilemap.local_to_map(position), -1)
		GameManager.pickup_mirror()
		queue_free()

