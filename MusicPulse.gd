# MusicPulse.gd
extends Control

@export var pulse_strength = 0.8
@export var base_scale = Vector2.ONE

func _process(_delta):
	# Just read the pre-smoothed value from the global Autoload
	var energy = AudioAnalyzer.smoothed_energy
	
	# Apply to scale (using pivot_offset in the editor to pulse from center!)
	scale = base_scale + (Vector2.ONE * energy * pulse_strength)
