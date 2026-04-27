extends Resource
class_name ModuleData

@export var id: String = "laser_basic" # Unique ID for custom code checks
@export var display_name: String = "Laser"
@export var collision: bool = true
@export var extra_data: Dictionary

## Use this for both static and animated modules
@export var sprite_frames: SpriteFrames
