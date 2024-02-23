extends Node



func _on_play_pressed():
	Fade.fade_and_change_scene("res://src/puzzle/puzzles/puzzle1.tscn")

func _on_quit_pressed():
	get_tree().quit()
