extends Node2D

@export var cell_size: int = 16 # Updated to match your 16x16 modules
@export var debug_module: ModuleData 

var active_modules: Dictionary = {} 
var is_editing: bool = true 

func _process(_delta: float) -> void:
	if not is_editing: 
		if has_node("GhostPreview"): $GhostPreview.visible = false
		return
	
	var grid_coords = _get_mouse_grid_coords()
	_update_ghost_preview(grid_coords)

func _input(event: InputEvent) -> void:
	if not is_editing: return
	
	if event.is_action_pressed("place_tile"):
		var grid_coords = _get_mouse_grid_coords()
		
		# LOUD DEBUG: See why it's failing
		var can_place = _can_place_here(grid_coords)
		print("Attempting placement at ", grid_coords, " | Valid Slot: ", can_place, " | Has Data: ", debug_module != null)
		
		if can_place and debug_module:
			place_module(debug_module, grid_coords)

# --- Snap to 16x16 Grid ---

func _get_mouse_grid_coords() -> Vector2i:
	var m_pos = get_local_mouse_position()
	
	# For 16x16, we want to snap to the nearest 16-pixel chunk
	return Vector2i(
		round(m_pos.x / cell_size),
		round(m_pos.y / cell_size)
	)

func _can_place_here(coords: Vector2i) -> bool:
	# 1. Already occupied?
	if active_modules.has(coords): 
		return false
	
	# 2. Clicking the player core (0,0)? (Usually blocked)
	if coords == Vector2i.ZERO: 
		return false
	
	# 3. Structural Rule: Must touch (0,0) or another module
	# We'll check all 4 neighbors
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var neighbor_pos = coords + dir
		if neighbor_pos == Vector2i.ZERO or active_modules.has(neighbor_pos):
			return true
			
	return false

func place_module(module_data: ModuleData, pos: Vector2i):
	var new_module = preload("res://base_module.tscn").instantiate() as BaseModule
	
	# 1. Assign data FIRST (while it's just an object in memory)
	new_module.data = module_data
	new_module.grid_pos = pos
	new_module.position = Vector2(pos) * cell_size
	
	# 2. Add to tree SECOND (this triggers _ready() and custom logic)
	add_child(new_module)
	
	active_modules[pos] = new_module
	_refresh_neighborhood(pos)
	print("SUCCESS: Module placed at ", pos)
	
func _update_ghost_preview(coords: Vector2i):
	var ghost = get_node_or_null("GhostPreview")
	
	if not ghost:
		# If you see this in the console, the name is wrong or it's missing
		push_warning("GhostPreview node not found!")
		return
	
	# Force visibility ON
	ghost.visible = true
	
	# Position it
	ghost.position = Vector2(coords) * cell_size
	
	# Update the frames from the debug module
	if debug_module and debug_module.sprite_frames:
		if ghost is AnimatedSprite2D:
			ghost.sprite_frames = debug_module.sprite_frames
			ghost.play("default")
		elif ghost is Sprite2D:
			# Fallback if you haven't converted the node yet
			push_warning("GhostPreview is a Sprite2D, but ModuleData uses SpriteFrames!")
	else:
		# If no frames, we use a placeholder so we can at least see WHERE it is
		ghost.visible = false 

	# Color Feedback
	if _can_place_here(coords):
		ghost.modulate = Color(0, 1, 0, 0.6) # Bright Green
	else:
		ghost.modulate = Color(1, 0, 0, 0.6) # Bright Red
		
func remove_module(pos: Vector2i):
	if not active_modules.has(pos): return
	
	var module = active_modules[pos]
	active_modules.erase(pos)
	module.queue_free()
	_refresh_neighborhood(pos)

func _refresh_neighborhood(pos: Vector2i):
	var to_update = [pos, pos+Vector2i.UP, pos+Vector2i.DOWN, pos+Vector2i.LEFT, pos+Vector2i.RIGHT]
	for coords in to_update:
		if active_modules.has(coords):
			active_modules[coords].update_neighbors(active_modules)
