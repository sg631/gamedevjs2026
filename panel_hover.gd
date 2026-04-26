extends PanelContainer

# Pre-define your colors or export them for the inspector
var normal_color: Color = Color(0.129, 0.133, 0.137)
var hover_color: Color = Color(1.392, 1.392, 1.392, 0.075)

func _ready():
	# Initial setup: ensure the panel has its own unique StyleBox to avoid 
	# changing all other panels accidentally.
	var sb = get_theme_stylebox("panel").duplicate()
	sb.bg_color = normal_color
	add_theme_stylebox_override("panel", sb)

func _on_mouse_entered():
	# Update the duplicate stylebox or create a new one
	var sb = get_theme_stylebox("panel").duplicate()
	sb.bg_color = hover_color
	add_theme_stylebox_override("panel", sb)
	print("MOUSE ENTERED")

func _on_mouse_exited():
	var sb = get_theme_stylebox("panel").duplicate()
	sb.bg_color = normal_color
	add_theme_stylebox_override("panel", sb)
