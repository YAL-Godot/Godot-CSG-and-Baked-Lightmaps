# Button to activate the painting and show the paint panel

@tool
extends Button

class_name PluginButton

var root :Node
var csg :CSGShape3D

# Show button in UI, untoggled
func show_button(root: Node, csg :CSGShape3D):
	self.root = root
	self.csg = csg
	show()

# Hide button in UI, untoggled
func hide_button():
	hide()

func _on_PluginButton_pressed() -> void:
	convert_csg_to_meshinstance()
	for node in csg.get_parent().get_children():
		if not (node is LightmapGI): continue
		# https://github.com/godotengine/godot/issues/59217
		pass

func unwrap_uv2(mesh_instance:MeshInstance3D):
	var old_mesh = mesh_instance.mesh
	var mesh = ArrayMesh.new()
	for surface_id in range(old_mesh.get_surface_count()):
		mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES, 
			old_mesh.surface_get_arrays(surface_id)
		)
		var old_mat = old_mesh.surface_get_material(surface_id)
		mesh.surface_set_material(surface_id, old_mat)
	mesh.lightmap_unwrap(mesh_instance.global_transform, 1./16.)
	mesh_instance.use_in_baked_light = true
	mesh_instance.mesh = mesh

func convert_csg_to_meshinstance():
	var csg_name = csg.name
	var mesh_name = csg_name + "_mesh"
	var mesh_instance:MeshInstance3D = csg.get_parent().get_node(mesh_name)
	var add_mesh = mesh_instance == null
	if (add_mesh):
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = mesh_name
		mesh_instance.owner = root
	
	var csg_mesh:Mesh = csg.get_meshes()[1].duplicate()
	var csg_transform = csg.global_transform
	mesh_instance.mesh = csg_mesh
	mesh_instance.global_transform = csg.global_transform
	unwrap_uv2(mesh_instance)
	if (add_mesh):
		csg.add_sibling(mesh_instance)
	else:
		mesh_instance.visible = true
	csg.visible = false
