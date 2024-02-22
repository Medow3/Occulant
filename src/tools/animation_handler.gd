class_name AnimationHandler extends Node

@export var animation_tree_node_names: Array[String]
@export var current_animation: String

@onready var player: AnimationPlayer = $AnimationPlayer
@onready var tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = tree.get("parameters/playback")


func travel_to_with_blend(animation: String, blend_position: Vector2, reset_if_running: bool = false) -> void:
	travel_to(animation, reset_if_running)
	set_blend(blend_position)

# Travels to the desired animation via the shortest route
func travel_to(animation: String, reset_if_running: bool = false) -> void:
	assert(animation in animation_tree_node_names, "Animation traveled to not in animation tree node names")
	if reset_if_running and current_animation == animation:
		tree.set("parameters/Seek/seek_position", 0.0)
	else:
		current_animation = animation
		state_machine.travel(animation)

# Sets blend position for the animation tree
func set_blend(blend_position: Vector2) -> void:
	tree.set("parameters/" + current_animation + "/blend_position", blend_position)
