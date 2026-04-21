extends Label

@onready var wave_manager: Node2D = $/root/MainScene/WaveManager

func _process(_delta: float) -> void:
	if not wave_manager: return
	
	if wave_manager.current_state == wave_manager.State.INTERMISSION:
		if wave_manager.intermission_timer:
			var time_left = wave_manager.intermission_timer.time_left
			text = "Next Wave in: %d" % ceil(time_left)
		else:
			text = "Starting..."
	else:
		# If you want to keep the "Survive" text during combat
		text = "Wave %d: SURVIVE" % wave_manager.current_wave
