extends Node2D # Note: For physics to work, this node or its parent must be a CharacterBody2D

@export var cell_size: int = 16 
@export var debug_module: ModuleData 
var active_modules: Dictionary = {} 
@export var is_editing: bool = true 

# Helper dictionary to track which hitbox belongs to which module
var module_hitboxes: Dictionary = {}

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
		var can_place = _can_place_here(grid_coords) 
		if can_place and debug_module: 
			place_module(debug_module, grid_coords) 

func _get_mouse_grid_coords() -> Vector2i: 
	var m_pos = get_local_mouse_position() 
	return Vector2i(round(m_pos.x / cell_size), round(m_pos.y / cell_size)) 

func _can_place_here(coords: Vector2i) -> bool: 
	if active_modules.has(coords): return false 
	if coords == Vector2i.ZERO: return false 
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]: 
		var neighbor_pos = coords + dir 
		if neighbor_pos == Vector2i.ZERO or active_modules.has(neighbor_pos): 
			return true 
	return false 

func place_module(module_data: ModuleData, pos: Vector2i): 
	var new_module = preload("res://base_module.tscn").instantiate() as BaseModule 
	new_module.data = module_data 
	new_module.grid_pos = pos 
	new_module.position = Vector2(pos) * cell_size 
	add_child(new_module) 
	active_modules[pos] = new_module 

	if debug_module.collision == true:
		var new_hitbox = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(cell_size, cell_size) # Matches your 16x16 grid
		new_hitbox.shape = shape
		new_hitbox.position = new_module.position # Sync with module visual position
	
		get_parent().add_child(new_hitbox)
		module_hitboxes[pos] = new_hitbox # Store reference to remove it later

	_refresh_neighborhood(pos) 
	is_editing = false
	print("SUCCESS: Module and Hitbox placed at ", pos) 

func remove_module(pos: Vector2i): 
	if not active_modules.has(pos): return 
	
	# Clean up visual module
	var module = active_modules[pos] 
	active_modules.erase(pos) 
	module.queue_free() 

	# --- NEW: REMOVE COLLISION ---
	if module_hitboxes.has(pos):
		var hitbox = module_hitboxes[pos]
		module_hitboxes.erase(pos)
		hitbox.queue_free()
	# -----------------------------

	_refresh_neighborhood(pos) 

func _update_ghost_preview(coords: Vector2i): 
	var ghost = get_node_or_null("GhostPreview") 
	if not ghost: return 
	ghost.visible = true 
	ghost.position = Vector2(coords) * cell_size 
	if debug_module and debug_module.sprite_frames: 
		if ghost is AnimatedSprite2D: 
			ghost.sprite_frames = debug_module.sprite_frames 
			ghost.play("default") 
	if _can_place_here(coords): 
		ghost.modulate = Color(0, 1, 0, 0.6) 
	else: 
		ghost.modulate = Color(1, 0, 0, 0.6) 

func _refresh_neighborhood(pos: Vector2i): 
	var to_update = [pos, pos+Vector2i.UP, pos+Vector2i.DOWN, pos+Vector2i.LEFT, pos+Vector2i.RIGHT] 
	for coords in to_update: 
		if active_modules.has(coords): 
			active_modules[coords].update_neighbors(active_modules)
