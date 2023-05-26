# Button to activate the painting and show the paint panel

@tool
extends Button

class_name PluginButtonHide

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
	var csg_name = csg.name
	var mesh_name = csg_name + "_mesh"
	var mesh_instance:MeshInstance3D = csg.get_parent().get_node(mesh_name)
	if (mesh_instance == null): return
	mesh_instance.visible = false
	csg.visible = true
