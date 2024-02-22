class_name SingleSFXData extends Resource

## The actual sound effect file to be played.
@export var sound_file: AudioStream

@export_group("Pitch")
## The default pitch of the sound effect.
@export_range(0.01, 4, 0.01, "or_greater", "or_lesser") var pitch_scale: float = 1.0
## Make the sound effect play at a random pitch each time.
## It could play this ammount higher or lower.
@export var pitch_random: float = 0.0

@export_group("Volume")
## Check this if you want the custom_volume to be used instead of the default volume.
@export var use_custom_sfx_volume: bool = false
@export_range(-80, 24, 0.001, "or_greater", "or_lesser") var custom_volume: float

@export_group("Bus Effects")
## Used for effects that apply to all sound effects. For example, setting reverb
## for all sound effects based on the size of each room. 
## UI sound shouldn't have these effects so set this to false for those.
@export var uses_environmental_effects_bus: bool = true
## The bus that the sound effect will be piped into.
## If left black, the sound effect will be piped through either the default
## sound effect bus or the environmental bus.
@export var bus_override: String = ""
## A list of audio effects that will be applied to the sound effect.
## A new bus will be created with these effects each time this is played.
## The bus will be removed after it finishes. 
@export var custom_effects_list: Array[AudioEffect] = []

@export_group("Tweening")
@export_subgroup("Fade In")
@export var do_fade_in: bool = false
@export var fade_in_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var fade_in_ease: Tween.EaseType = Tween.EASE_IN
@export var fade_in_duration: float = 0.1

@export_subgroup("Fade Out")
@export var do_fade_out: bool = false
@export var fade_out_trans: Tween.TransitionType = Tween.TRANS_SINE
@export var fade_out_ease: Tween.EaseType = Tween.EASE_IN
@export var fade_out_duration: float = 0.1

## Only used for AudioStreamPlayer2D's.
## Will be ignored otherwise.
@export_group("2D")
## Determines which Area2D layers affect the sound for reverb and audio bus effects. 
## Areas can be used to redirect AudioStreams so that they play in a certain audio bus. 
@export var area_mask: int = 1
## The volume is attenuated over distance with this as an exponent.
@export var attenuation: float = 1.0
## Maximum distance from which audio is still hearable.
@export var max_distance: float = 2000.0
## Scales the panning strength for this node by multiplying the base ProjectSettings.audio/general/2d_panning_strength with this factor. 
## Higher values will pan audio from left to right more dramatically than lower values.
@export var panning_strength: float = 1.0

# Make sure this is the name of the sound effects bus in the default_bus_layout.tres
const SOUND_EFFECT_AUDIO_BUS_NAME: String = "Sound Effects"
const EVIRONMENT_AUDIO_BUS_NAME: String = "Environment"
const DEFAULT_SFX_VOLUME: float = -4.0
const FADE_OFF_VALUE: float = -80.0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func set_up_and_play(my_player, tween: Tween, remove_bus_func: Callable) -> void:
	assert(my_player is AudioStreamPlayer or my_player is AudioStreamPlayer2D, "Invalid audio player type.")
	_set_up_parameters(my_player)
	_set_up_bus_effects(my_player, remove_bus_func)
	_set_up_tweening(my_player, tween)
	_set_up_2d_paramters(my_player)
	my_player.play()


func _set_up_parameters(my_player) -> void:
	my_player.stream = sound_file
	my_player.pitch_scale = pitch_scale
	if use_custom_sfx_volume:
		my_player.volume_db = custom_volume
	else:
		my_player.volume_db = DEFAULT_SFX_VOLUME
	my_player.pitch_scale = _rng.randf_range(pitch_scale - pitch_random, pitch_scale + pitch_random)


func _set_up_bus_effects(my_player, remove_bus_func: Callable) -> void:
	if bus_override != "":
		my_player.bus = bus_override
	elif uses_environmental_effects_bus:
		my_player.bus = EVIRONMENT_AUDIO_BUS_NAME
	else:
		my_player.bus = SOUND_EFFECT_AUDIO_BUS_NAME
	
	if len(custom_effects_list) <= 0:
		return
	
	var bus_id: int = AudioServer.bus_count
	var new_bus_name: String = "custom_sfx_bus_" + str(bus_id)
	AudioServer.add_bus(bus_id)
	AudioServer.set_bus_name(bus_id, new_bus_name)
	if bus_override != "":
		AudioServer.set_bus_send(bus_id, bus_override)
	elif uses_environmental_effects_bus:
		AudioServer.set_bus_send(bus_id, EVIRONMENT_AUDIO_BUS_NAME)
	else:
		AudioServer.set_bus_send(bus_id, SOUND_EFFECT_AUDIO_BUS_NAME)
	
	for effect in custom_effects_list:
		AudioServer.add_bus_effect(bus_id, effect, bus_id)
	my_player.bus = new_bus_name
	
	remove_bus_func.call(bus_id, sound_file.get_length())


func _set_up_tweening(my_player, tween: Tween) -> void:
	# If we are looping we don't actually want to fade out.
	# Fading out of looping sound effects is done by the fade_out_looping_sfx function
	var actually_doing_fade_out: bool = do_fade_out and sound_file.loop_mode == sound_file.LOOP_DISABLED
	if not do_fade_in and not actually_doing_fade_out:
		return
	
	var sound_file_length: float = sound_file.get_length()
	if do_fade_in and actually_doing_fade_out:
		assert(fade_in_duration + fade_out_duration < sound_file_length, "Fade in and out durations cannot overlap.")
	
	var fade_into_volume: float = 0.0
	if use_custom_sfx_volume:
		fade_into_volume = custom_volume
	else:
		fade_into_volume = DEFAULT_SFX_VOLUME
	tween.set_parallel(true)
	
	if do_fade_in:
		assert(fade_in_duration < sound_file_length, "Fade in duration cannot be longer than the sound effect length.")
		tween.tween_property(my_player, "volume_db", fade_into_volume, fade_in_duration).from(FADE_OFF_VALUE).set_ease(fade_in_ease).set_trans(fade_in_trans)
	
	if actually_doing_fade_out:
		assert(fade_out_duration < sound_file_length, "Fade out duration cannot be longer than the sound effect length.")
		var fade_out_delay: float = sound_file_length - fade_out_duration
		tween.tween_property(my_player, "volume_db", FADE_OFF_VALUE, fade_out_duration).from(fade_into_volume).set_ease(fade_out_ease).set_trans(fade_out_trans).set_delay(fade_out_delay)


func _set_up_2d_paramters(my_player) -> void:
	if not my_player is AudioStreamPlayer2D:
		return
	
	my_player.area_mask = area_mask
	my_player.attenuation = attenuation
	my_player.max_distance = max_distance
	my_player.panning_strength = panning_strength


func fade_out_looping_sfx(my_player, tween: Tween) -> void:
	if do_fade_out:
		tween.tween_property(my_player, "volume_db", FADE_OFF_VALUE, fade_out_duration).set_ease(fade_out_ease).set_trans(fade_out_trans)
		await tween.finished
	my_player.stop()
