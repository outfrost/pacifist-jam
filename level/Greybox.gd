tool
extends CollisionShape

const MESH_SCENE = preload("res://level/GreyboxMeshInstance.tscn")

export var extents: Vector3 = Vector3(0.5, 0.5, 0.5) setget set_extents
export var material: Material setget set_material
export var baked: bool = false

onready var mesh_instance = get_node_or_null("GreyboxMeshInstance")
onready var body = $StaticBody
onready var collision_shape = $StaticBody/CollisionShape

func _ready() -> void:
	if Engine.editor_hint && get_parent() is Viewport:
		return

	shape = null
	generate_mesh_instance()

	if Engine.editor_hint:
		shape = BoxShape.new()
		shape.extents = extents
	else:
		var s = BoxShape.new()
		s.extents = extents
		collision_shape.shape = s

	set_extents(extents)

func _process(delta: float) -> void:
	if !Engine.editor_hint || !shape:
		return
	var shape_extents = (shape as BoxShape).extents
	if !extents.is_equal_approx(shape_extents):
		set_extents(shape_extents)

func generate_mesh_instance() -> void:
	if mesh_instance:
		remove_child(mesh_instance)
		mesh_instance.queue_free()
		mesh_instance = null
	if !baked:
		mesh_instance = MESH_SCENE.instance()
		add_child(mesh_instance)
		mesh_instance.mesh = mesh_instance.mesh.duplicate()
		mesh_instance.material_override = material

func set_extents(value: Vector3):
	extents = value
	if mesh_instance:
		(mesh_instance.mesh as CubeMesh).size = value * 2.0
	property_list_changed_notify()

func set_material(value: Material):
	material = value
	if mesh_instance:
		mesh_instance.material_override = material

func set_baked(value: bool):
	baked = value
	if !baked:
		generate_mesh_instance()
		set_extents(extents)
