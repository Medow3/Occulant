class_name CustomRandomGenerator extends Node

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready():
	_rng.randomize()

# Pick and return a value from a weighted dictionary.
# A weighted dictionary has {value: weight} as elements.
func get_random_weighted_value(weighted_dict: Dictionary):
	assert(len(weighted_dict) != 0, "Weighted dictionary cannot be empty")
	
	var sum_of_weights: float = 0
	for element in weighted_dict:
		sum_of_weights += weighted_dict[element]

	var random_weight: float = _rng.randf() * sum_of_weights

	var cumulative_weight: float = 0
	for element in weighted_dict:
		cumulative_weight += weighted_dict[element]
		if random_weight < cumulative_weight:
			return element
	
	push_error("get_random_weighted_value error")
	return
