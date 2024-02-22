class_name Player extends CharacterBody2D

signal about_to_reflect

@export var tilemap: TileMap
@export var reflection_tile_distance: int = 5

@onready var mirror_line: Line2D = $mirror_line
@onready var square: Sprite2D = $square
@onready var animation_handler = $animation_handler

const SPEED = 100.0

var facing_direction: Vector2 = Vector2.LEFT
var previewing: bool = false

func _physics_process(delta):
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
		return
	
	var input_direction: Vector2 = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = input_direction * SPEED
	
	if input_direction != Vector2.ZERO:
		facing_direction = input_direction.normalized()
		animation_handler.travel_to_with_blend("walk", facing_direction)
	else:
		animation_handler.travel_to_with_blend("idle", facing_direction)
		
	
	if Input.is_action_just_pressed("Reflect"):
		if GameManager.get_number_of_mirrors_in_inventory() > 0:
			if not previewing:
				previewing = true
			else:
				previewing = false
				reflect()
				GameManager.use_mirror()
	elif Input.is_action_just_pressed("Cancel Reflect"):
		if GameManager.get_number_of_mirrors_in_inventory() > 0:
			if previewing:
				previewing = false
	
	move_and_slide()
	update_reflection_preview()


func update_reflection_preview() -> void:
	if previewing:
		var reflection_direction: Vector2 = facing_direction
		reflection_direction.x = sign(round(reflection_direction.x))
		reflection_direction.y = sign(round(reflection_direction.y))
		
		mirror_line.visible = true
		var player_map_grid_cords: Vector2i = tilemap.local_to_map(global_position)
		mirror_line.global_position = tilemap.map_to_local(player_map_grid_cords)
		mirror_line.global_rotation = atan2(reflection_direction.y, reflection_direction.x)
		square.visible = true
		square.global_position = tilemap.map_to_local(player_map_grid_cords)
	else:
		mirror_line.visible = false
		square.visible = false


func reflect() -> void:
	emit_signal("about_to_reflect")
	var facing_axis: Vector2 = facing_direction
	facing_axis.x = round(facing_axis.x)
	facing_axis.y = round(facing_axis.y)
	
	var perpendicular_axis_3d: Vector3 = Vector3(facing_axis.x, facing_axis.y, 0).cross(Vector3(0, 0, 1))
	var perpendicular_axis: Vector2 = Vector2(perpendicular_axis_3d.x, perpendicular_axis_3d.y)
	
	var player_map_grid_cords: Vector2i = tilemap.local_to_map(global_position)
	var top_left_of_side1: Vector2i
	var bottom_right_of_side1: Vector2i
	var top_left_of_side2: Vector2i
	var bottom_right_of_side2: Vector2i
	if abs(facing_axis.x) == 1:
		top_left_of_side1 = player_map_grid_cords + Vector2i(
				-facing_axis.x * reflection_tile_distance, perpendicular_axis.y * reflection_tile_distance)
		bottom_right_of_side1 = player_map_grid_cords + Vector2i(
				-facing_axis.x * 1, -perpendicular_axis.y * reflection_tile_distance)
		
		top_left_of_side2 = player_map_grid_cords + Vector2i(
				facing_axis.x * 1, perpendicular_axis.y * reflection_tile_distance)
		bottom_right_of_side2 = player_map_grid_cords + Vector2i(
				facing_axis.x * reflection_tile_distance, -perpendicular_axis.y * reflection_tile_distance)
		if facing_axis.x == -1:
			var temp: Vector2i = bottom_right_of_side1
			bottom_right_of_side1 = top_left_of_side1
			top_left_of_side1 = temp
			
			temp = bottom_right_of_side2
			bottom_right_of_side2 = top_left_of_side2
			top_left_of_side2 = temp
	elif abs(facing_axis.y) == 1:
		top_left_of_side1 = player_map_grid_cords + Vector2i(
				-perpendicular_axis.x * reflection_tile_distance, -facing_axis.y * reflection_tile_distance)
		bottom_right_of_side1 = player_map_grid_cords + Vector2i(
				perpendicular_axis.x * reflection_tile_distance, -facing_axis.y * 1)
		
		top_left_of_side2 = player_map_grid_cords + Vector2i(
				-perpendicular_axis.x * reflection_tile_distance, facing_axis.y * 1)
		bottom_right_of_side2 = player_map_grid_cords + Vector2i(
				perpendicular_axis.x * reflection_tile_distance, facing_axis.y * reflection_tile_distance)
		
		if facing_axis.y == -1:
			var temp: Vector2i = bottom_right_of_side1
			bottom_right_of_side1 = top_left_of_side1
			top_left_of_side1 = temp
			
			temp = bottom_right_of_side2
			bottom_right_of_side2 = top_left_of_side2
			top_left_of_side2 = temp
	
	
	var reflected_side1_pattern: TileMapPattern = create_reflected_pattern_for_side(top_left_of_side1, bottom_right_of_side1, facing_axis)
	var nonoverritable_side1_pattern: TileMapPattern = create_reflected_pattern_for_side(top_left_of_side1, bottom_right_of_side1, facing_axis, true)
	var reflected_side2_pattern: TileMapPattern = create_reflected_pattern_for_side(top_left_of_side2, bottom_right_of_side2, facing_axis)
	var nonoverritable_side2_pattern: TileMapPattern = create_reflected_pattern_for_side(top_left_of_side2, bottom_right_of_side2, facing_axis, true)
	
	tilemap.set_pattern(0, top_left_of_side1, reflected_side2_pattern)
	tilemap.set_pattern(0, top_left_of_side2, reflected_side1_pattern)
	tilemap.set_pattern(0, top_left_of_side1, nonoverritable_side1_pattern)
	tilemap.set_pattern(0, top_left_of_side2, nonoverritable_side2_pattern)


func create_reflected_pattern_for_side(top_left: Vector2i, bottom_right: Vector2i, facing_axis: Vector2, only_nonoverritable: bool = false) -> TileMapPattern:
	var reflected_pattern: TileMapPattern = TileMapPattern.new()
	for x in range(top_left.x, bottom_right.x + 1):
		for y in range(top_left.y, bottom_right.y + 1):
			var tilemap_cell_coords: Vector2i = Vector2i(x, y)
			
			var tile_data: TileData = tilemap.get_cell_tile_data(0, tilemap_cell_coords)
			
			var unmoveable = false
			if not only_nonoverritable:
				if tile_data != null:
					unmoveable = tile_data.get_custom_data("unmoveable")
					if unmoveable:
						continue
				reflected_pattern.set_cell(
					get_reflected_pattern_coords(tilemap_cell_coords, top_left, bottom_right, facing_axis),
					tilemap.get_cell_source_id(0, tilemap_cell_coords) if not unmoveable else -1,
					tilemap.get_cell_atlas_coords(0, tilemap_cell_coords),
					tilemap.get_cell_alternative_tile(0, tilemap_cell_coords)
				)
			else:
				if tile_data != null:
					var nonoverritable = tile_data.get_custom_data("unmoveable")
					if not nonoverritable:
						continue
				else:
					continue
				reflected_pattern.set_cell(
					tilemap_cell_coords - top_left,
					tilemap.get_cell_source_id(0, tilemap_cell_coords),
					tilemap.get_cell_atlas_coords(0, tilemap_cell_coords),
					tilemap.get_cell_alternative_tile(0, tilemap_cell_coords)
				)
	return reflected_pattern


func get_reflected_pattern_coords(coord: Vector2i, top_left: Vector2i, bottom_right: Vector2i, facing_axis: Vector2) -> Vector2i:
	var normalized_bottom_right: Vector2i = bottom_right - top_left
	var normalized_coord: Vector2i = coord - top_left
	var normalized_reflected_coord: Vector2i
	
	var reflection_vector: Vector2i
	if abs(facing_axis.x) == 1:
		reflection_vector = Vector2i(normalized_bottom_right.x, 0)
	elif abs(facing_axis.y) == 1:
		reflection_vector = Vector2i(0, normalized_bottom_right.y)
	
	normalized_reflected_coord = abs(normalized_coord - reflection_vector)
	
	return normalized_reflected_coord
