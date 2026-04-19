# AudioAnalyzer.gd (Autoload as "AudioAnalyzer")
extends Node

var spectrum: AudioEffectSpectrumAnalyzerInstance
var min_db = -60
var smoothed_energy = 0.0

@export var smooth_speed = 1.0 # Adjust for more/less "floaty" feel

func _ready():
	# Make sure your "Music" bus has the Spectrum Analyzer effect at index 0
	var bus_idx = AudioServer.get_bus_index("Music")
	spectrum = AudioServer.get_bus_effect_instance(bus_idx, 0)

func _process(delta: float):
	if not spectrum: return
	
	# 1. Get magnitude
	var mag = spectrum.get_magnitude_for_frequency_range(20, 150).length()
	
	# 2. Convert to energy (forced to float with 0.0 and 1.0)
	var raw_energy: float = clamp((linear_to_db(mag) - min_db) / (-min_db), 0.0, 1.0)
	
	# 3. Smooth the value
	# Ensure smooth_speed is also treated as a float
	smoothed_energy = lerp(smoothed_energy, raw_energy, float(smooth_speed) * delta)
