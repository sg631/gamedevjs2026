# wave_manager.gd
extends Node2D

signal wave_started(number: int)
signal wave_finished(number: int)

enum State { INTERMISSION, COMBAT }

@export var enemy_pool: Array[EnemyDefinition] = []
@export var intermission_time: float = 5.0
@onready var player: Node2D = $/root/MainScene/Player

var current_state: State = State.INTERMISSION
var current_wave: int = 1
var active_enemies: int = 0

var intermission_timer: SceneTreeTimer # Keep a reference

func _ready() -> void:
	start_intermission()

# Inside wave_manager.gd

func start_intermission() -> void:
	current_state = State.INTERMISSION
	intermission_timer = get_tree().create_timer(intermission_time)
	
	# Wait for it to finish
	await intermission_timer.timeout
	
	# Clear it after use so the UI knows it's gone
	intermission_timer = null 
	start_combat()

func start_combat() -> void:
	current_state = State.COMBAT
	active_enemies = 0
	wave_started.emit(current_wave)
	
	for definition in enemy_pool:
		var count = definition.get_amount(current_wave)
		if count > 0:
			_spawn_enemy_group(definition, count)
	
	if active_enemies == 0:
		end_combat()

func _spawn_enemy_group(definition: EnemyDefinition, count: int) -> void:
	# Calculate the angle step for even distribution (TAU is 2*PI)
	var angle_step = TAU / count
	
	for i in range(count):
		var enemy = definition.enemy_scene.instantiate()
		active_enemies += 1
		
		# Connect the death signal
		if enemy.has_signal("removed"):
			enemy.removed.connect(_on_enemy_removed)
		
		# Calculate position: Player Pos + (Vector at Angle * Distance)
		var spawn_angle = i * angle_step
		var spawn_offset = Vector2.RIGHT.rotated(spawn_angle) * definition.spawn_distance
		
		add_child(enemy)
		enemy.global_position = player.global_position + spawn_offset
		
func _on_enemy_removed() -> void:
	active_enemies -= 1
	if active_enemies <= 0 and current_state == State.COMBAT:
		end_combat()

func end_combat() -> void:
	wave_finished.emit(current_wave)
	current_wave += 1
	start_intermission()
