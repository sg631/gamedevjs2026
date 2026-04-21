extends TileMapLayer

@export var is_editing: bool = false
var source_id = 0 
var tile_atlas_coords = Vector2i(0, 0)

# The center of your player in tile coordinates
const PLAYER_CENTER = Vector2i(0, 0)

func _process(_delta: float) -> void:
	if not is_editing:
		$PreviewSprite.visible = false
		return
	
	$PreviewSprite.visible = true
	var tile_coords = local_to_map(get_local_mouse_position())
	$PreviewSprite.position = map_to_local(tile_coords)
	
	if _can_place_at(tile_coords):
		$PreviewSprite.modulate = Color(0.6, 1.0, 0.6, 0.5) # Greenish
	else:
		$PreviewSprite.modulate = Color(1.0, 0.6, 0.6, 0.5) # Reddish

func _input(event):
	if not is_editing: return

	var tile_coords = local_to_map(get_local_mouse_position())

	if event.is_action_pressed("place_tile"):
		if _can_place_at(tile_coords):
			set_cell(tile_coords, source_id, tile_atlas_coords)
			_on_modules_changed()

	elif event.is_action_pressed("remove_tile"):
		# Prevent deleting the player center if you represent the player as a tile
		if tile_coords != PLAYER_CENTER:
			erase_cell(tile_coords)
			_on_modules_changed()

func _can_place_at(coords: Vector2i) -> bool:
	# 1. Disable placing on top of the player's core
	if coords == PLAYER_CENTER: return false
	
	# 2. Disable adding to a slot already used
	if get_cell_source_id(coords) != -1: return false
	
	# 3. Check for neighbors (including player)
	return _has_valid_connection(coords)

func _has_valid_connection(coords: Vector2i) -> bool:
	var neighbors = get_surrounding_cells(coords)
	for n in neighbors:
		# If neighbor is the player center OR neighbor has a tile
		if n == PLAYER_CENTER or get_cell_source_id(n) != -1:
			return true
	return false

# Use this to track all modules for your automation logic
func get_all_modules() -> Array[Vector2i]:
	return get_used_cells()

func _on_modules_changed():
	var count = get_used_cells().size()
	print("Total Modules Attached: ", count)
