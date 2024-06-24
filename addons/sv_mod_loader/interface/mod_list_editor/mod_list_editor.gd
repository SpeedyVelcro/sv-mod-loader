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
@export var mod_array_editor: Node
## Popup for new mod list
@export var new_mod_list_window: Window


## Name of the currently selected mod list
var mod_list_name: String = ""

# Override
func _ready():
	var mod_array: Array[Mod] = _get_mods_in_mod_path()
	mod_array_editor.set_mod_array(mod_array)


## Save the currently selected mod list
func _save_current() -> void:
	var path: String = _name_to_path(mod_list_name)
	var mod_list: ModList = get_mod_list()
	
	var include_name: bool = false # Name is stored in file name instead
	var dict: Dictionary = mod_list.serialize(false)
	var json: String = JSON.stringify(dict, "\t")
	
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json)


## Load the currently selected mod list
func _load_current() -> void:
	var path: String = _name_to_path(mod_list_name)
	var mod_list: ModList = ModList.new()
	mod_list.name = mod_list_name
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open " + path)
		_set_mod_list(mod_list)
		return
	
	var json_string = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse_string(json_string)
	
	if error != OK:
		push_error("Failed to parse JSON from file " + path)
		_set_mod_list(mod_list)
		return
	
	if not (json.data is Dictionary):
		push_warning("Mod list was not a dictionary.")
		_set_mod_list(mod_list)
		return
	
	var include_name: bool = false # We already set the name
	mod_list.deserialize(json.data, include_name)
	
	_set_mod_list(mod_list)


## Select a mod list. Saves the current mod list and loads the selected one.
func _select(new_name: String) -> void:
	_save_current()
	mod_list_name = new_name
	_load_current()


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
func _is_filename_mod(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\.[pP][cC][kK]$")
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Returns true if the given filename is a mod list by checking the extension
func _is_filename_mod_list(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\.[mM][lL][iI]$")
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Gets the current configuration as a ModList
func get_mod_list() -> ModList:
	var mod_array: Array[Mod] = mod_array_editor.get_mod_array()
	var mod_list: ModList = ModList.new()
	
	mod_list.name = _path_to_name(mod_list_path)
	mod_list.load_order = mod_array_editor.get_mod_array()
	
	return mod_list


## Configures according to given ModList
func _set_mod_list(mod_list: ModList) -> void:
	mod_list_name = _name_to_path(mod_list.name)
	mod_array_editor.update_mod_array(mod_list.load_order)


## Configures as a new ModList with the given name
func _new_mod_list(new_name: String) -> void:
	var mod_list: ModList = ModList.new()
	mod_list.name = new_name
	_set_mod_list(mod_list)
	# TODO: sort alphabetically?


## Configures as a new ModList with the same name as the current one
func _copy_mod_list(new_name: String) -> void:
	var mod_list: ModList = get_mod_list()
	mod_list.name = new_name
	_set_mod_list(mod_list)


## Converts a mod list file path to the name of the mod list
func _path_to_name(path: String) -> String:
	path = path.trim_prefix(mod_list_path)
	path = path.trim_suffix(".mli")
	
	return path


## Converts a name of a mod list to the corresponding file path
func _name_to_path(name_to_convert: String) -> String:
	return mod_list_path + "/" + name_to_convert + ".mli"


# Signal connection
func _on_new_button_pressed() -> void:
	new_mod_list_window.popup_centered()


# Signal connection
func _on_delete_button_pressed() -> void:
	pass # TODO


# Signal connection
func _on_option_button_item_selected(index) -> void:
	pass # TODO


func _on_new_mod_list_window_confirm(new_name, is_copy):
	if is_copy:
		_copy_mod_list(new_name)
	else:
		_new_mod_list(new_name)
