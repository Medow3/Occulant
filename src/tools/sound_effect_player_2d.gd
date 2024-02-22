class_name SoundEffectPlayer2D extends Node2D

## The number of audio players to instanciate.
## The more audio players the more sounds that can be played in paralell.
@export var paralel_tracks: int = 3
## If this is set, the audio player will play this SFXData, then delete itself.
@export var one_shot_sfx: SFXData = null

const DEFAULT_VOLUME: float = -4.0

var _crng: CustomRandomGenerator = CustomRandomGenerator.new()
var _audio_players_list: Array = []
var _next_open_player_index: int = 0

func _ready() -> void:
	if one_shot_sfx != null:
		paralel_tracks = 1
		var new_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(new_player)
		_audio_players_list.append(new_player)
		play_sfx(one_shot_sfx)
		return
	
	for i in range(paralel_tracks):
		var new_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		add_child(new_player)
		_audio_players_list.append(new_player)


func _process(delta: float) -> void:
	if one_shot_sfx != null:
		if not _audio_players_list[0].playing:
			queue_free()


func play_sfx(sfx_data: SFXData) -> void:
	var single_sfx_data: SingleSFXData = sfx_data.get_sfx()
	var audio_players_list_length: int = len(_audio_players_list)
	var next_player: AudioStreamPlayer2D = _audio_players_list[_next_open_player_index]
	if next_player.playing:
		for i in range(_next_open_player_index, _next_open_player_index + audio_players_list_length):
			var check_index: int = i % audio_players_list_length
			var check_player: AudioStreamPlayer2D = _audio_players_list[check_index]
			if not check_player.playing:
				next_player = check_player
				_next_open_player_index = check_index
				break
	
	if not next_player.playing:
		var tween: Tween = get_tree().create_tween()
		single_sfx_data.set_up_and_play(next_player, tween, SFX.remove_bus_after_time)
		_next_open_player_index += 1
		_next_open_player_index %= audio_players_list_length


func stop_looping_sfx(sfx_data: SFXData) -> void:
	var sfx_list: Array = []
	if sfx_data.single_sfx != null:
		sfx_list.append(sfx_data.single_sfx.sound_file)
	if sfx_data.sfx_pool != null:
		for i in sfx_data.sfx_pool.SFX_pool:
			sfx_list.append(i.sfx_data.sound_file)
		
	for i in _audio_players_list:
		if i.stream in sfx_list and i.playing:
			var tween: Tween = get_tree().create_tween()
			sfx_data.single_sfx.fade_out_looping_sfx(i, tween)
