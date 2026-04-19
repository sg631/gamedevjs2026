extends CharacterBody2D

@export var max_speed: float = 30.0
@export var acceleration: float = 10.0 # Higher = faster takeoff
@export var friction: float = 15.0     # Higher = faster stop
@export var stop_distance: float = 20.0 # Prevents jittering at the target

@onready var player = get_parent().get_node("Player")

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
		
		move_and_slide()
		
		# Rotation has been removed per your request. 
		# The enemy will move towards the player while remaining upright.
