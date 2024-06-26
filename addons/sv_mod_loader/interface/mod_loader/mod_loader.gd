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
## Scene to change to when the "Play" button is pressed. Should be set to the
## path (starting with "res://") of any *.tscn file.
@export_file("*.tscn") var play_scene: String = ""

@export_group("Internal Nodes")
## Child mod list editor scene
@export var mod_list_editor: Node


# Override
func _init() -> void:
	# This is done in the "init" step to get ahead of the "ready" step, which is
	# when all other scenes use these values
	ModListSaver.path = mod_list_path
	ModScanner.path = mod_path


## Switches to the set "play scene". Set save_first to true to save all configs
## before leaving the mod loader.
func play(save_first = true) -> void:
	if save_first:
		save()
	
	if play_scene == "":
		push_warning("Play scene not set on ModLoader")
		return
	
	var success = load_mods()
	if not success:
		push_error("Failed to load mods. Aborting play.")
		# TODO: Popup a message box to the user (not just logging to console)
		# Might have to re-organize some things so we can display the mod name
		# here
		return
	
	get_tree().change_scene_to_file(play_scene)


## Loads mods in the order configured in the mod_list_editor. Returns true if
## successful. Pushes an error (unless you specify not to) and returns false
## if unsuccessful
func load_mods(push_error = true) -> bool:
	save()
	
	var mod_list: ModList = mod_list_editor.get_mod_list()
	
	for mod: Mod in mod_list.load_order:
		if not mod.enabled:
			continue
		
		var path = ModScanner.filename_to_absolute_path(mod.filename)
		
		var success = ProjectSettings.load_resource_pack(path)
		
		if not success:
			push_error("Failed to load mod as resource pack: " + mod.filename)
			return false
	
	return true


## Saves any currently unsaved configs
func save() -> void:
	mod_list_editor.save_current()


# Signal connection
func _on_quit_button_pressed() -> void:
	save()
	get_tree().quit()


# Signal connection
func _on_play_button_pressed() -> void:
	play()
