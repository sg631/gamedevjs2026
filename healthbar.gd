extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	size.x = ($/root/MainScene/Player.health/float($/root/MainScene/Player.maxhealth)) * get_parent().size.x
