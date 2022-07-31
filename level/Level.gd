extends Spatial

const AVATAR_SCENE = preload("res://avatar/Avatar.tscn")

onready var spawn_point = $SpawnPoint
onready var menu_camera = $MenuCamera
onready var music = $Music

var avatar
var active: bool = false

func _ready() -> void:
	$DeathArea.connect("body_entered", self, "death_area_entered")

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("restart_level"):
		restart()

func death_area_entered(body) -> void:
	if body == avatar:
		restart()

func start() -> void:
	menu_camera.current = false
	yeet_avatar()
	spawn_avatar()
	music.play()
	active = true

func stop() -> void:
	active = false
	music.stop()
	yeet_avatar()
	menu_camera.current = true

func restart() -> void:
	yeet_avatar()
	spawn_avatar()

func spawn_avatar() -> void:
	avatar = AVATAR_SCENE.instance()
	add_child(avatar)
	avatar.transform = spawn_point.transform
	avatar.camera.current = true

func yeet_avatar() -> void:
	if avatar:
		avatar.camera.current = false
		spawn_point.remove_child(avatar)
		avatar.queue_free()
		avatar = null
