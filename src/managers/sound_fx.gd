extends Node

@export_dir var sound_fx_directory_path: String = "res://assets/audio/sound_effects/"

@onready var audio_players: Node = $audio_players
@onready var audio_players_list: Array = audio_players.get_children()

var _next_open_player_index: int = 0


func play_sfx(sfx_data: SFXData) -> void:
	var single_sfx_data: SingleSFXData = sfx_data.get_sfx()
	var audio_players_list_length: int = len(audio_players_list)
	var next_player: AudioStreamPlayer = audio_players_list[_next_open_player_index]
	if next_player.playing:
		for i in range(_next_open_player_index, _next_open_player_index + audio_players_list_length):
			var check_index: int = i % audio_players_list_length
			var check_player: AudioStreamPlayer = audio_players_list[check_index]
			if not check_player.playing:
				next_player = check_player
				_next_open_player_index = check_index
				break
	
	if not next_player.playing:
		var tween: Tween = get_tree().create_tween()
		single_sfx_data.set_up_and_play(next_player, tween, remove_bus_after_time)
		_next_open_player_index += 1
		_next_open_player_index %= audio_players_list_length


func stop_looping_sfx(sfx_data: SFXData) -> void:
	var sfx_list: Array = []
	if sfx_data.single_sfx != null:
		sfx_list.append(sfx_data.single_sfx.sound_file)
	if sfx_data.sfx_pool != null:
		for i in sfx_data.sfx_pool.SFX_pool:
			sfx_list.append(i.sfx_data.sound_file)
		
	for i in audio_players_list:
		if i.stream in sfx_list and i.playing:
			var tween: Tween = get_tree().create_tween()
			sfx_data.single_sfx.fade_out_looping_sfx(i, tween)


func stop_all_sfx(fade_out_length: float) -> void:
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_parallel()
	for i: AudioStreamPlayer in audio_players.get_children():
		if i.playing:
			tween.tween_property(i, "volume_db", -80.0, fade_out_length)
	await tween.finished
	for i: AudioStreamPlayer in audio_players.get_children():
		i.stop()


# Using this because the AudioStreamPlayer finished signal doesn't work.
func remove_bus_after_time(bus_id: int, seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	AudioServer.remove_bus(bus_id)
