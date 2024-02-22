extends Node

signal mirrors_in_inventory_changed(mirrors_in_inventory: int)

var _mirrors_in_inventory: int = 1000


func pickup_mirror() -> void:
	_mirrors_in_inventory += 1
	emit_signal("mirrors_in_inventory_changed", _mirrors_in_inventory)


func use_mirror() -> bool:
	if _mirrors_in_inventory > 0:
		_mirrors_in_inventory -= 1
		emit_signal("mirrors_in_inventory_changed", _mirrors_in_inventory)
		return true
	return false


func set_number_of_mirrors_in_inventory(new_value: int) -> void:
	_mirrors_in_inventory = new_value
	emit_signal("mirrors_in_inventory_changed", _mirrors_in_inventory)


func get_number_of_mirrors_in_inventory() -> int:
	return _mirrors_in_inventory
