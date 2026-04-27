extends CharacterBody2D

const SPEED = 100
@export var def_maxhealth: float = 100
@export var maxhealth: float = 100
@export var health: float = 100
@export var module_stats: Dictionary[String, int] = {
	"healths":0,
	"speeds":0
}
@export var base_stats: Dictionary[String, int] = {
	"health":1,
	"speed":1
}

@export var module_stat_penalty = 0.25
@export var point_stat_penalty = 0.75

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	var calcspeed = SPEED + ((SPEED * point_stat_penalty)*(base_stats.speed-1)) + ((SPEED * module_stat_penalty)*module_stats.speeds)
	maxhealth = def_maxhealth + ((def_maxhealth * point_stat_penalty)*(base_stats.health-1)) + ((def_maxhealth * module_stat_penalty)*module_stats.speeds)

	# normalize() automatically scales diagonal vectors by 1/√2, keeping speed consistent
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * calcspeed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, calcspeed)

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
