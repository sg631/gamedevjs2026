extends Node2D
class_name BaseModule

# --- Properties ---
var data: ModuleData:
	set(value):
		data = value
		_update_visuals()

var grid_pos: Vector2i

var neighbors: Dictionary = {
	Vector2i.UP: null,
	Vector2i.DOWN: null,
	Vector2i.LEFT: null,
	Vector2i.RIGHT: null
}

# --- Signals ---
signal removed(pos: Vector2i, module_data: ModuleData)

# --- Lifecycle ---
func _ready() -> void:
	_update_visuals()
	
	# Juice: Pop-in animation
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _exit_tree() -> void:
	# Emit the signal for the inventory system to refund the item
	removed.emit(grid_pos, data)

# --- Logic ---

## Called by GridManager. Updates references and checks for isolation.
func update_neighbors(manager_grid: Dictionary) -> void:
	var has_any_neighbor: bool = false
	
	for direction in neighbors.keys():
		var target_coords = grid_pos + direction
		
		# Check if the neighbor is the Player Core (0,0) or another module
		if target_coords == Vector2i.ZERO or manager_grid.has(target_coords):
			neighbors[direction] = manager_grid.get(target_coords)
			has_any_neighbor = true
		else:
			neighbors[direction] = null
	
	# If this isn't the core and it has lost all connections, it falls off
	if not has_any_neighbor and grid_pos != Vector2i.ZERO:
		queue_free()

## Updates the Sprite2D texture based on the ModuleData Resource
func _update_visuals() -> void:
	if not is_inside_tree(): return
	
	if data and has_node("Sprite2D"):
		$Sprite2D.texture = data.texture
