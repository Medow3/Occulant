extends PointLight2D

@export var ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var trans: Tween.TransitionType = Tween.TRANS_SINE
@export var energy_min: float = 0
@export var energy_max: float = 1
@export var texture_scale_min: float = 0
@export var texture_scale_max: float = 1
@export var length: float = 1
@export var delay: float = 0.1

func _ready() -> void:
	var tween: Tween = create_tween().set_loops().set_ease(ease).set_trans(trans)
	tween.tween_property(self, "energy", energy_min, length).set_delay(delay)
	tween.tween_property(self, "energy", energy_max, length).set_delay(delay)
	
	var tween2: Tween = create_tween().set_loops().set_ease(ease).set_trans(trans)
	tween2.tween_property(self, "texture_scale", texture_scale_min, length).set_delay(delay)
	tween2.tween_property(self, "texture_scale", texture_scale_max, length).set_delay(delay)
