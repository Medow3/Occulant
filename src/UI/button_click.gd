extends Button

@onready var hover_sfx: SFXData = load("res://src/resources/cutsom_sfx/button_hover_sfx_data.tres")
@onready var clicked_sfx: SFXData = load("res://src/resources/cutsom_sfx/button_click_sfx_data.tres")

func _ready() -> void:
	mouse_entered.connect(_play_hover_sfx)
	button_down.connect(_play_clicked_sfx)


func _play_hover_sfx() -> void:
	SFX.play_sfx(hover_sfx)


func _play_clicked_sfx() -> void:
	SFX.play_sfx(clicked_sfx)
