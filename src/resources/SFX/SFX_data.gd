class_name SFXData extends Resource

## A list of all the posible sound effects that can be played. Can contain only 1 SFX.
@export var SFX_pool: Array[SingleSFXData]
## A list of all the weights for sound effects.
@export var SFX_pool_weights: Array[float] = [1.0]
## Wether or not the same sound effect can be played twice in a row.
@export var prevent_same_sound_twice_in_a_row: bool = true

var last_played_sfx_data: SingleSFXData = null
var _crng: CustomRandomGenerator = CustomRandomGenerator.new()


func get_sfx() -> SingleSFXData:
	if len(SFX_pool) == 1:
		last_played_sfx_data = SFX_pool[0]
		return SFX_pool[0]
	
	var weighted_sfx_dict: Dictionary = {}
	for i in range(len(SFX_pool)):
		weighted_sfx_dict[SFX_pool[i]] = SFX_pool_weights[i]
	if prevent_same_sound_twice_in_a_row:
		weighted_sfx_dict.erase(last_played_sfx_data)
	
	var random_sfx: SingleSFXData = _crng.get_random_weighted_value(weighted_sfx_dict)
	last_played_sfx_data = random_sfx
	return random_sfx
