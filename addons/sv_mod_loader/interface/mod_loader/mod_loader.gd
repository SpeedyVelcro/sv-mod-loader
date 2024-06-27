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


# Override
func _init():
	ModListSaver.path = mod_list_path
	ModScanner.path = mod_path


func _on_quit_button_pressed():
	mod_list_editor.save_current()
	get_tree().quit()
