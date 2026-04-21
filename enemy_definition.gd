# enemy_definition.gd
extends Resource
class_name EnemyDefinition

@export_group("Visuals")
@export var enemy_scene: PackedScene

@export_group("Logic")
@export var amount_expression: String = "10"
@export var spawn_distance: float = 600.0 # Distance from player

@export_group("Schedule")
@export var start_wave: int = 1
@export var end_wave: int = 9999

func get_amount(wave_number: int) -> int:
	if wave_number < start_wave or wave_number > end_wave:
		return 0
	var expr = Expression.new()
	var error = expr.parse(amount_expression, ["w", "wave"])
	if error != OK: return 0
	var result = expr.execute([wave_number, wave_number], null)
	return int(result) if result != null else 0
