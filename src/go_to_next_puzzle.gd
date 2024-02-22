extends Area2D

@export var next_puzzle_path: String

func _on_body_entered(body):
	if body is Player:
		Fade.fade_and_change_scene(next_puzzle_path)
