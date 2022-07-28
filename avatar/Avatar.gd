extends KinematicBody

const SPEED: float = 5.0
const ACCEL: float = 10.0
const JUMP_SPEED: float = 7.0
const GRAVITY: float = 10.0

onready var camera: Camera = $Camera

var mouse_sens: float = 1.0
var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var target_xz_velocity = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	).clamped(1.0) * SPEED

	target_xz_velocity = target_xz_velocity.rotated(- rotation.y)

	var xz_velocity_delta: Vector2 = target_xz_velocity - Vector2(velocity.x, velocity.z)
	var xz_velocity: Vector2 = (
		Vector2(velocity.x, velocity.z)
		+ xz_velocity_delta * min(xz_velocity_delta.length(), ACCEL * delta)
	)

	velocity.x = xz_velocity.x
	velocity.z = xz_velocity.y

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_SPEED

	velocity.y -= GRAVITY * delta

	velocity = move_and_slide(velocity, Vector3.UP)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var rotation = - event.relative / get_tree().root.size.y
		rotate_y(rotation.x * mouse_sens)
		var pitch_delta: float = clamp(
			rotation.y * mouse_sens,
			- 0.25 * TAU - camera.rotation.x,
			0.25 * TAU - camera.rotation.x
		)
		camera.rotate_x(pitch_delta)
