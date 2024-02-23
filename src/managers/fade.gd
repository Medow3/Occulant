extends CanvasLayer

@export var fade_color: Color = Color.BLACK

@onready var color_rect = $Control/FadeColorRect

const DEFAULT_FADE_LENGTH: float = 0.3
const DEFAULT_FADE_MID_DELAY: float = 0.0
const DEFAULT_FADE_EASE: Tween.EaseType = Tween.EASE_IN
const DEFAULT_FADE_TRANS: Tween.TransitionType = Tween.TRANS_SINE

var currently_fading: bool = false


func _ready():
	color_rect.color = fade_color
	color_rect.color.a = 0.0


func fade_and_change_scene(scene_path: String, 
		fade_length: float = DEFAULT_FADE_LENGTH, 
		fade_mid_delay: float = DEFAULT_FADE_MID_DELAY, 
		fade_ease: Tween.EaseType = DEFAULT_FADE_EASE, 
		fade_trans: Tween.TransitionType = DEFAULT_FADE_TRANS) -> void:
	
	var change_scene_function: Callable = func (go_to_scene_path: String):
		SFX.stop_all_sfx(fade_length)
		get_tree().change_scene_to_file(go_to_scene_path)
	
	fade_out_call_func_fade_in(change_scene_function, [scene_path], fade_length, fade_mid_delay, fade_ease, fade_trans)


func fade_and_reload_scene( 
		fade_length: float = DEFAULT_FADE_LENGTH, 
		fade_mid_delay: float = DEFAULT_FADE_MID_DELAY, 
		fade_ease: Tween.EaseType = DEFAULT_FADE_EASE, 
		fade_trans: Tween.TransitionType = DEFAULT_FADE_TRANS) -> void:
	
	var reload_scene_function: Callable = func ():
		get_tree().reload_current_scene()
	
	fade_out_call_func_fade_in(reload_scene_function, [], fade_length, fade_mid_delay, fade_ease, fade_trans)


func fade_out_call_func_fade_in(function: Callable = Callable(), function_argvs: Array = [],
		fade_length: float = DEFAULT_FADE_LENGTH, 
		fade_mid_delay: float = DEFAULT_FADE_MID_DELAY, 
		fade_ease: Tween.EaseType = DEFAULT_FADE_EASE, 
		fade_trans: Tween.TransitionType = DEFAULT_FADE_TRANS) -> void:
	
	if currently_fading:
		return
	
	currently_fading = true
	var fade_tween: Tween = create_tween().set_ease(fade_ease).set_trans(fade_trans)
	fade_tween.tween_property(color_rect, "color:a", 1.0, fade_length).from(0.0)
	fade_tween.tween_property(color_rect, "color:a", 0.0, fade_length).from(1.0).set_delay(fade_mid_delay)
	await fade_tween.step_finished
	function.callv(function_argvs)
	await fade_tween.finished
	fade_tween.kill()
	currently_fading = false
