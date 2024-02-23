extends Label


func _ready() -> void:
	var player: Player = get_tree().get_first_node_in_group("Player")
	player.about_to_reflect.connect(_go_away)

func _go_away() -> void:
	visible = false
