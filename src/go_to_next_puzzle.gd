extends Area2D

@export var next_puzzle_path: String
@export var win_sfx: SFXData

func _on_body_entered(body):
	if body is Player:
		SFX.play_sfx(win_sfx)
		Fade.fade_and_change_scene(next_puzzle_path)
