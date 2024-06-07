extends Control
## Main SV Mod Loader interface
##
## This scene contains a full interface that allows setup of a mod load order
## and starting the game with that load order.

## Path of directory where mod lists are stored. Used to overwrite the same
## property configured on mod_list_editor.
@export var mod_list_path: String = "user://mod_lists"
## Path of directory where mods are stored. Used to overwrite the same property
## configured on mod_list_editor.
@export var mod_path: String = "user://mods"
@export_group("Internal Nodes")
## Child mod list editor scene
@export var mod_list_editor: Node


func _on_mod_list_editor_tree_entered():
	# Using tree_entered signal because this needs to be done before ready,
	# which is when mod_list_editor uses these values
	mod_list_editor.mod_list_path = mod_list_path
	mod_list_editor.mod_path = mod_path
