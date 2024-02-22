class_name Puzzle extends Node

@export var start_with_reflection_uses: int = 1


func _ready():
	GameManager.set_number_of_mirrors_in_inventory(start_with_reflection_uses)
