class_name UI extends Control


@onready var mirrors_left_label = $HBoxContainer/mirrors_in_inventory


func _ready():
	GameManager.mirrors_in_inventory_changed.connect(set_mirrors_text)
	set_mirrors_text(GameManager.get_number_of_mirrors_in_inventory())


func set_mirrors_text(new_value: int) -> void:
	mirrors_left_label.text = str(new_value)
