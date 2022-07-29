extends Spatial

const AVATAR_SCENE = preload("res://avatar/Avatar.tscn")

onready var spawn_point = $SpawnPoint
onready var menu_camera = $MenuCamera

var avatar
var active: bool = false

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("restart_level"):
		restart()

func start() -> void:
	menu_camera.current = false
	yeet_avatar()
	spawn_avatar()
	active = true

func stop() -> void:
	active = false
	yeet_avatar()
	menu_camera.current = true

func restart() -> void:
	yeet_avatar()
	spawn_avatar()

func spawn_avatar() -> void:
	avatar = AVATAR_SCENE.instance()
	spawn_point.add_child(avatar)
	avatar.camera.current = true

func yeet_avatar() -> void:
	if avatar:
		avatar.camera.current = false
		spawn_point.remove_child(avatar)
		avatar.queue_free()
		avatar = null
