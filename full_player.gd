extends CharacterBody2D

const SPEED = 100
@export var health: int = 100

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	# normalize() automatically scales diagonal vectors by 1/√2, keeping speed consistent
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	# --- Animation ---
	if direction == Vector2.ZERO:
		$AnimSprite.stop()
	elif direction.x != 0:
		# Horizontal or diagonal: side animation, flip for left
		$AnimSprite.flip_h = direction.x < 0
		$AnimSprite.play("walk_side")
	elif direction.y < 0:
		$AnimSprite.flip_h = false
		$AnimSprite.play("walk_up")
	else:
		$AnimSprite.flip_h = false
		$AnimSprite.play("walk_down")

	move_and_slide()
