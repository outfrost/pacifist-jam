tool
extends Spatial

const BAKED_MESH_INSTANCE_SCENE = preload("res://level/BakedMeshInstance.tscn")
const Greybox = preload("res://level/Greybox.gd")

export var bake: bool = false setget set_bake
export var unbake: bool = false setget set_unbake
export var default_material: Material

onready var bake_root: Spatial = get_node_or_null("_BakeRoot")

var progress: int = 0
var total_greyboxes: int = 0

func clean() -> void:
	bake_root = get_node_or_null("_BakeRoot")
	if !bake_root:
		bake_root = Spatial.new()
		bake_root.name = "_BakeRoot"
		add_child(bake_root)
		bake_root.owner = owner

	for child in bake_root.get_children():
		bake_root.remove_child(child)
		child.queue_free()

func bake() -> void:
	clean()

	progress = 0
	total_greyboxes = count_greyboxes_recursive(self)

	bake_meshes_recursive(self)
	print("Finished baking")

func count_greyboxes_recursive(node: Spatial) -> int:
	var count = 0
	for child in node.get_children():
		count += count_greyboxes_recursive(child)
		if child is Greybox:
			count += 1
	return count

func bake_meshes_recursive(node: Spatial) -> void:
	for child in node.get_children():
		bake_meshes_recursive(child)
		if child is Greybox:
			progress += 1
			print("Baking Greybox %d/%d" % [progress, total_greyboxes])
			child.set_baked(false)
			child.set_baked(true)
			if !child.mesh_instance || !child.mesh_instance.mesh:
				print("No MeshInstance or Mesh here")
				continue

			var array_mesh = ArrayMesh.new()
			array_mesh.add_surface_from_arrays(
				Mesh.PRIMITIVE_TRIANGLES,
				(child.mesh_instance.mesh as PrimitiveMesh).get_mesh_arrays())
			array_mesh.surface_set_material(0, default_material)

			var baked_instance = BAKED_MESH_INSTANCE_SCENE.instance()
			bake_root.add_child(baked_instance)
			baked_instance.owner = owner
			baked_instance.global_transform = child.mesh_instance.global_transform
			baked_instance.mesh = array_mesh
			baked_instance.material_override = child.mesh_instance.material_override

			child.remove_child(child.mesh_instance)
			child.mesh_instance.queue_free()
			child.mesh_instance = null

			var result = array_mesh.lightmap_unwrap(baked_instance.global_transform, 0.2)
			if result != OK:
				print_debug("UV2 unwrap failed for", array_mesh, ":", result)

func unbake() -> void:
	clean()
	var count: int = unbake_meshes_recursive(self)
	print("Unbaked %d Greyboxes" % count)

func unbake_meshes_recursive(node: Spatial) -> int:
	var count: int = 0
	for child in node.get_children():
		count += unbake_meshes_recursive(child)
		if child is Greybox:
			child.set_baked(false)
			count += 1
	return count

func set_bake(value: bool) -> void:
	if !Engine.editor_hint:
		return
	if value:
		bake()

func set_unbake(value: bool) -> void:
	if !Engine.editor_hint:
		return
	if value:
		unbake()
