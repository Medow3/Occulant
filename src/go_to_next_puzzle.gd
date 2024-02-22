extends Area2D

@export var next_puzzle_path: String

func _on_body_entered(body):
	if body is Player:
		get_tree().change_scene_to_file(next_puzzle_path)
