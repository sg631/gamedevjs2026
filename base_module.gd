extends Node2D
class_name BaseModule

# --- Properties ---
var data: ModuleData:
	set(value):
		data = value
		_update_visuals()

var grid_pos: Vector2i
var neighbors: Dictionary = {
	Vector2i.UP: null, Vector2i.DOWN: null, 
	Vector2i.LEFT: null, Vector2i.RIGHT: null
}

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
	
	# EXECUTE CUSTOM CODE BASED ON ID
	_initialize_custom_logic()

func _exit_tree() -> void:
	removed.emit(grid_pos, data)

# --- Visuals ---

func _update_visuals() -> void:
	if not is_inside_tree() or not data: return
	
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and data.sprite_frames:
		sprite.sprite_frames = data.sprite_frames
		sprite.play("default") # Ensure your SpriteFrames has a "default" animation
	elif not data.sprite_frames:
		push_warning("Module %s is missing SpriteFrames!" % data.id)

# --- Custom Logic System ---

func _initialize_custom_logic() -> void:
	match data.id:
		"laser_basic":
			print("Logic: Setting up basic laser cooldowns...")
		"energy_gen":
			print("Logic: Connecting to power grid...")
		"shield_battery":
			# You can even call functions on neighbors here
			pass

func update_neighbors(manager_grid: Dictionary) -> void:
	var has_any_neighbor: bool = false
	for direction in neighbors.keys():
		var target_coords = grid_pos + direction
		if target_coords == Vector2i.ZERO or manager_grid.has(target_coords):
			neighbors[direction] = manager_grid.get(target_coords)
			has_any_neighbor = true
		else:
			neighbors[direction] = null
	
	if not has_any_neighbor and grid_pos != Vector2i.ZERO:
		queue_free()
