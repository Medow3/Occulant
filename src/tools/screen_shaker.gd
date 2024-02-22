class_name ScreenShaker extends Node

@export var camera: Camera2D

@onready var f_timer: Timer = $frequency
@onready var d_timer: Timer = $duration

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT
const DEFAULT_OFFSET = Vector2(0, -10)

var amplitude: float = 0
var priority: float = 0


func start(duration = 0.2, frequency: float = 15.0, input_amplitude = 16, input_priority = 0) -> void:
	#if Settings.screen_shake <= 0.0:
		#return
	
	if priority >= self.priority:
		priority = input_priority
		amplitude = input_amplitude# * Settings.screen_shake
		d_timer.wait_time = duration
		f_timer.wait_time = 1 / frequency
		d_timer.start()
		f_timer.start()
		_new_shake()


func _new_shake() -> void:
	var rand: Vector2 = Vector2.ZERO
	rand.x = randf_range(-1 * amplitude, amplitude)
	rand.y = randf_range(-1 * amplitude, amplitude)
	
	var tween: Tween = get_tree().create_tween().set_ease(EASE).set_trans(TRANS)
	tween.tween_property(camera, "offset", DEFAULT_OFFSET + rand, f_timer.wait_time)


func _reset() -> void:
	var tween: Tween = get_tree().create_tween().set_ease(EASE).set_trans(TRANS)
	tween.tween_property(camera, "offset", DEFAULT_OFFSET, f_timer.wait_time)
	priority = 0


func _on_frequency_timeout() -> void:
	_new_shake()


func _on_duration_timeout() -> void:
	_reset()
	f_timer.stop()
