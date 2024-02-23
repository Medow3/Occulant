extends Control

@onready var reflection_preview_button = $reflection_preview_toggle
@onready var music_enabled_button = $music

func _ready():
	reflection_preview_button.button_pressed = Settings.preview_reflections_enabled
	music_enabled_button.button_pressed = Settings.music_enabled


func _on_back_pressed():
	Fade.fade_and_change_scene("res://src/UI/main_menu/main_menu.tscn")


func _on_reflection_preview_toggle_toggled(toggled_on):
	Settings.preview_reflections_enabled = reflection_preview_button.button_pressed


func _on_music_toggled(toggled_on):
	Settings.music_enabled = toggled_on
	if Settings.music_enabled:
		Music.play_song(load("res://assets/music/gamejam_demo1.mp3"))
	else:
		Music.stop_song()
		
