extends KinematicBody

const SPEED: float = 5.0
const ACCEL: float = 10.0
const JUMP_SPEED: float = 7.0
const GRAVITY: float = 10.0

var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var target_xz_velocity = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	).clamped(1.0) * SPEED

	target_xz_velocity = target_xz_velocity.rotated(rotation.y)

	velocity.x = move_toward(velocity.x, target_xz_velocity.x, ACCEL * delta)
	velocity.z = move_toward(velocity.z, target_xz_velocity.y, ACCEL * delta)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED

	velocity.y -= GRAVITY * delta

	velocity = move_and_slide(velocity, Vector3.UP)
