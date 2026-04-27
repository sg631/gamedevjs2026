extends CharacterBody2D

@export var max_speed: float = 30.0
@export var acceleration: float = 10.0 # Higher = faster takeoff
@export var friction: float = 15.0     # Higher = faster stop
@export var stop_distance: float = 5.0 # Prevents jittering at the target
@export var health: float = 100
@export var ModuleType : ModuleData

@onready var player = $/root/MainScene/Player

signal removed

func _physics_process(delta: float) -> void:
	if player:
		var distance = global_position.distance_to(player.global_position)
		var direction = global_position.direction_to(player.global_position)
		
		if distance > stop_distance:
			# Gradually smooth velocity towards the target speed
			var target_velocity = direction * max_speed
			velocity = velocity.lerp(target_velocity, acceleration * delta)
		else:
			# Smoothly slow down if close enough
			velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		
		
	if health <= 0:
		$/root/MainScene/Player/ModuleGrid.is_editing = true;
		$/root/MainScene/Player/ModuleGrid.debug_module = ModuleType
		queue_free()
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Collided with: ", collision.get_collider().name)
		if "health" in collision.get_collider() && collision.get_collider().name == "Player":
			collision.get_collider().health -= 10 * delta
func _exit_tree():
	# If the enemy is freed for any reason, let the manager know
	removed.emit()
