class_name Puzzle extends Node

@export var start_with_reflection_uses: int = 1

@onready var player: Player = $Player
@onready var tilemap: TileMap = $TileMap
@onready var undo_sfx: SFXData = load("res://src/resources/cutsom_sfx/undo_sfx_data.tres")

var _history: Array[Dictionary] = []
var current_place_in_history: int = 0

func _ready():
	GameManager.set_number_of_mirrors_in_inventory(start_with_reflection_uses)
	player.about_to_reflect.connect(_save_state)


func _save_state() -> void:
	if len(_history) > 0 and current_place_in_history < len(_history) - 1:
		while len(_history) > current_place_in_history:
			_history.pop_back()
	var new_state: Dictionary = {}
	new_state["tiles"] = tilemap.get_pattern(0, tilemap.get_used_cells(0))
	new_state["top_left_tile_coord"] = tilemap.get_used_rect().position
	new_state["player_global_position"] = player.global_position
	new_state["mirrors_held"] = GameManager.get_number_of_mirrors_in_inventory()
	_history.append(new_state)
	current_place_in_history = len(_history)


func _load_state(state: Dictionary) -> void:
	print("load")
	SFX.play_sfx(undo_sfx)
	player.global_position = state["player_global_position"]
	tilemap.clear()
	tilemap.set_pattern(0, state["top_left_tile_coord"], state["tiles"])
	GameManager.set_number_of_mirrors_in_inventory(state["mirrors_held"])
	player.previewing = false


func _physics_process(delta):
	if Input.is_action_just_pressed("Undo"):
		if len(_history) > 0 and current_place_in_history > 0:
			current_place_in_history -= 1
			Fade.fade_out_call_func_fade_in(_load_state, [_history[current_place_in_history]], 0.1)
	elif Input.is_action_just_pressed("Redo"):
		if len(_history) > 0 and current_place_in_history < len(_history):
			Fade.fade_out_call_func_fade_in(_load_state, [_history[current_place_in_history]], 0.1)
			current_place_in_history += 1
