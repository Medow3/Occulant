extends Control

@export var open_close_sfx: SFXData

var is_active: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		set_active(not is_active)


func set_active(new_value: bool) -> void:
	SFX.play_sfx(open_close_sfx)
	get_tree().paused = new_value
	visible = new_value
	is_active = new_value
	

func _on_skip_pressed() -> void:
	set_active(false)
	var next_puzzle_path: String = get_tree().get_first_node_in_group("Puzzle End").next_puzzle_path
	Fade.fade_and_change_scene(next_puzzle_path)


func _on_main_menu_pressed() -> void:
	set_active(false)
	Fade.fade_and_change_scene("res://src/UI/main_menu/main_menu.tscn")


func _on_contineu_pressed() -> void:
	set_active(false)
