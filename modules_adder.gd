extends TileMapLayer

var source_id = 0 
var tile_atlas_coords = Vector2i(0, 0)

func _process(_delta: float) -> void:
	var tile_coords = local_to_map(get_local_mouse_position())
	$PreviewSprite.position = map_to_local(tile_coords)
	
	# Update tint based on neighbor check
	if _has_orthogonal_neighbor(tile_coords):
		$PreviewSprite.modulate = Color.from_rgba8(170, 255, 170, 127)
	else:
		$PreviewSprite.modulate = Color.from_rgba8(255, 170, 170, 127)


func _input(event):
	if event.is_action_pressed("place_tile"):
		var tile_coords = local_to_map(get_local_mouse_position())
		
		# Only place if the condition is met
		if _has_orthogonal_neighbor(tile_coords):
			set_cell(tile_coords, source_id, tile_atlas_coords)
			print("Placed tile at: ", tile_coords)
		else:
			print("Cannot place tile: No adjacent neighbor.")
	
	elif event.is_action_pressed("remove_tile"):
		var tile_coords = local_to_map(get_local_mouse_position())
		erase_cell(tile_coords)


# Helper function to check for non-diagonal neighbors
func _has_orthogonal_neighbor(coords: Vector2i) -> bool:
	# get_surrounding_cells returns [Left, Right, Top, Bottom] for square grids
	var neighbors = get_surrounding_cells(coords)
	
	for neighbor in neighbors:
		# get_cell_source_id returns -1 if the cell is empty
		if get_cell_source_id(neighbor) != -1:
			return true
			
	return false
