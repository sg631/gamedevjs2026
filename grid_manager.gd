# grid_manager.gd
extends Node2D

var active_modules: Dictionary = {} # Key: Vector2i, Value: BaseModule
@export var cell_size: int = 64

func place_module(module_data: ModuleData, pos: Vector2i):
	if active_modules.has(pos): return
	
	var new_module = preload("res://base_module.tscn").instantiate()
	new_module.data = module_data
	new_module.grid_pos = pos
	new_module.position = pos * cell_size
	
	add_child(new_module)
	active_modules[pos] = new_module
	
	# Tell the new module and its neighbors to refresh
	_refresh_neighborhood(pos)

func remove_module(pos: Vector2i):
	if not active_modules.has(pos): return
	
	var module = active_modules[pos]
	active_modules.erase(pos)
	module.queue_free()
	
	_refresh_neighborhood(pos)

func _refresh_neighborhood(pos: Vector2i):
	# Update the center and its 4 neighbors
	var to_update = [pos, pos+Vector2i.UP, pos+Vector2i.DOWN, pos+Vector2i.LEFT, pos+Vector2i.RIGHT]
	for coords in to_update:
		if active_modules.has(coords):
			active_modules[coords].update_neighbors(active_modules)
