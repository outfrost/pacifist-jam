extends KinematicBody

const SPEED: float = 5.0
const ACCEL: float = 10.0
const JUMP_SPEED: float = 6.0
const GRAVITY: float = 10.0

onready var camera: Camera = $Camera

var mouse_sens: float = 1.2
var velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
#	var target_xz_velocity: Vector2 = Vector2(1.0, 1.0).clamped(1.0) * SPEED
#	var xz_velocity: Vector2 = Vector2(0.0, 1.0) * SPEED
#	var delta = 0.00625
#
#	print("v ", xz_velocity)
#	print("speed ", xz_velocity.length())
#	for i in range(20):
##		print("--- iter ", i)
#		var delta_dir: Vector2 = (
#			target_xz_velocity
#			- project(target_xz_velocity, xz_velocity)
#		)
#		if delta_dir.length_squared() != 0.0:
#			delta_dir = delta_dir.normalized()
#		var step: Vector2 = delta_dir * ACCEL * delta
#		var ref: Vector2 = xz_velocity - project(xz_velocity, target_xz_velocity)
#		var step_proj: Vector2 = project(step, ref)
#		var step_proj_len: float = step.length()
#		var ref_len: float = ref.length()
#		if step_proj_len > ref_len && step_proj_len != 0.0:
#			step *= ref_len / step_proj_len
##		print("step ", step)
#		xz_velocity += step
#		print("v ", xz_velocity)
#		print("speed ", xz_velocity.length())
#	print("v ", xz_velocity)
#	print("speed ", xz_velocity.length())
	pass

func _process(delta: float) -> void:
	DebugOverlay.display("xz_speed %.1f" % Vector2(velocity.x, velocity.z).length())

func _physics_process(delta: float) -> void:
	var target_xz_dir: Vector2 = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	).clamped(1.0)
	target_xz_dir = target_xz_dir.rotated(- rotation.y)
	var target_xz_velocity: Vector2 = target_xz_dir * SPEED

	var xz_velocity: Vector2 = Vector2(velocity.x, velocity.z)
	var xz_speed: float = xz_velocity.length()

	# acceleration shenanigans
#	if !is_on_floor():
#		var speedup = max(xz_velocity.normalized().dot(target_xz_dir), 0.0)
#		speedup *= - (speedup * speedup) + speedup
#		speedup *= 0.05
#		if xz_speed > SPEED:
#			speedup *= sqrt(xz_speed)
#		target_xz_velocity *= speedup
#
#	if xz_speed > SPEED:
#		speedup /= 0.8 * xz_speed / SPEED
#	DebugOverlay.display("speedup %.4f" % speedup)
	xz_velocity = xz_velocity.move_toward(target_xz_velocity, ACCEL * delta)
#	xz_velocity *= 1.0 + speedup
#	if is_on_floor():
#		xz_velocity = xz_velocity.move_toward(xz_velocity.clamped(SPEED), ACCEL * delta)

#	var speedup = max(xz_velocity.normalized().dot(target_xz_dir), 0.0)
#	speedup *= - (speedup * speedup) + speedup
#	speedup *= 0.1
#	if xz_speed > SPEED:
#		speedup /= 0.8 * xz_speed / SPEED
#	DebugOverlay.display("speedup %.4f" % speedup)
#	xz_velocity = xz_velocity.move_toward(target_xz_velocity, ACCEL * delta)
#	xz_velocity *= 1.0 + speedup
#	if is_on_floor():
#		xz_velocity = xz_velocity.move_toward(xz_velocity.clamped(SPEED), ACCEL * delta)

#	if !is_on_floor():
		# airborne shenanigans
#		var delta_dir: Vector2 = (
#			target_xz_velocity
#			- project(target_xz_velocity, xz_velocity)
#		)
#		if delta_dir.length_squared() != 0.0:
#			delta_dir = delta_dir.normalized()
#		var step: Vector2 = delta_dir * ACCEL * delta
#		var ref: Vector2 = xz_velocity - project(xz_velocity, target_xz_velocity)
#		var step_proj: Vector2 = project(step, ref)
#		var step_proj_len: float = step.length()
#		var ref_len: float = ref.length()
#		if step_proj_len > ref_len && step_proj_len != 0.0:
#			step *= ref_len / step_proj_len
#		xz_velocity += step

#	else:
		# slerp
#		var v_dir: Vector2 = xz_velocity.normalized()
#		var target_dir: Vector2 = target_xz_velocity.normalized()
#		var dir: Vector2 = v_dir.slerp(target_dir, clamp(ACCEL * delta, 0.0, 1.0))
#		var target_speed = target_xz_velocity.length()
#		var cur_speed = xz_velocity.length()
#		if (target_speed == 0.0):
#			dir = v_dir
#		if (cur_speed == 0.0):
#			dir = target_dir
#		xz_velocity = dir * move_toward(cur_speed, target_speed, ACCEL * delta)

		# lerp
#		xz_velocity = xz_velocity.move_toward(target_xz_velocity, ACCEL * delta)

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

func project(v: Vector2, onto: Vector2) -> Vector2:
	if onto.length_squared() == 0.0:
		return Vector2.ZERO
	return v.project(onto)
