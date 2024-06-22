extends VBoxContainer
## UI Element for editing, selecting, saving and loading mod lists
##
## UI Element where you can choose and edit a mod list. You can also delete
## mod lists and create new ones.

## File path where mod lists are stored.
@export var mod_list_path: String = "user://mod_lists"
## File path where mods are stored.
@export var mod_path: String = "user://mods"

@export_group("Internal Nodes")
## Child load order editor
@export var load_order_editor: Node

# Override
func _ready():
	var mod_array: Array[Mod] = _get_mods_in_mod_path()
	load_order_editor.set_mod_array(mod_array)


## Gets an array of all mods on disk stored in the mod_path
func _get_mods_in_mod_path() -> Array[Mod]:
	# Forced to abandon type safety for most of this function as many in-built
	# functions return generic arrays.
	var filenames: Array = Array(DirAccess.get_files_at(mod_path))
	
	var mod_filenames: Array = filenames.filter(func(str: String): return _is_filename_mod(str))
	
	var mods: Array = mod_filenames.map(
		func(filename: String):
			var mod: Mod = Mod.new()
			mod.filename = filename
			return mod)
	
	# Quick hack at the end so we can return a typed array
	var mod_array: Array[Mod] = []
	mod_array.assign(mods)
	return mod_array


## Returns true if the given filename is a mod by checking the extension
func _is_filename_mod(filename: String):
	var regex = RegEx.new()
	regex.compile("\\.[pP][cC][kK]$")
	
	var results = regex.search_all(filename)
	
	return results.size() > 0
