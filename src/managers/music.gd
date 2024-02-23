extends Node

@onready var music_player = $music_player

const MUSIC_DIRECTORY_PATH = "res://assets/music/"
const DEFAULT_MUSIC_VOLUME: float = -26.0
const DEFAULT_CROSSFADE_TIME: float = 0.4
const MUSIC_CROSSFADE_TWEEN_TRANS := Tween.TRANS_SINE
const MUSIC_CROSSFADE_TWEEN_EASE := Tween.EASE_IN

var music_files: Dictionary = {}
var current_song: AudioStream

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if Settings.music_enabled:
		play_song(load("res://assets/music/gamejam_demo1.mp3"))


# Default use: Music.play_song("", Music.DEFAULT_MUSIC_VOLUME, Music.DEFAULT_CROSSFADE_TIME)
func play_song(new_song: AudioStream, volume: float = DEFAULT_MUSIC_VOLUME, fade_duration: float = DEFAULT_CROSSFADE_TIME) -> void:
	var tween: Tween = get_tree().create_tween().set_trans(MUSIC_CROSSFADE_TWEEN_TRANS).set_ease(MUSIC_CROSSFADE_TWEEN_EASE)
	tween.tween_property(music_player, "volume_db", -80, fade_duration).from_current()
	await tween.finished
	current_song = new_song
	music_player.stream = new_song
	music_player.play()
	tween = get_tree().create_tween().set_trans(MUSIC_CROSSFADE_TWEEN_TRANS).set_ease(MUSIC_CROSSFADE_TWEEN_EASE)
	tween.tween_property(music_player, "volume_db", volume, fade_duration).from(-80)

func stop_song() -> void:
	music_player.stop()
