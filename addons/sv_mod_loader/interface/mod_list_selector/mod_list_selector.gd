extends OptionButton
## UI element for selecting a mod list
##
## UI element that displays mod lists by names, and signals which mod list has
## has been selected by name.

## Emitted when a mod list is selected
signal mod_list_selected(selected_name: String)
## Emitted after repopulating if there are no mod lists left
signal empty

## File path where mod lists are stored.
@export var mod_list_path: String = "user://mod_lists"

## The last selected mod list by name
var _last_selected = ""


# Override
func _ready():
	repopulate()


## Clears and repopulates OptionButton with mod lists on disk.
## Selects first mod list if previously selected mod list is gone.
## Emits empty if there are no mod lists to select.
func repopulate() -> void:
	select(-1)
	clear()
	
	var mod_lists: Array[String] = _get_mod_lists_in_path()
	
	for i in mod_lists.size():
		add_item(mod_lists[i], i)
		if mod_lists[i] == _last_selected:
			select(i)
	
	if mod_lists.size() <= 0:
		empty.emit()
	elif selected < 0:
		select(0)


## Selects a mod list by name
func select_mod_list(mod_list_name: String) -> void:
	for i in item_count:
		if get_item_text(i) == mod_list_name:
			select(i)


## Gets an array of all mod lists on disk stored in the mod_list_path
func _get_mod_lists_in_path() -> Array[String]:
	# Forced to abandon type safety for most of this function as many in-built
	# functions return generic arrays.
	var filenames: Array = Array(DirAccess.get_files_at(mod_list_path))
	
	var list_filenames: Array = filenames.filter(func(str: String): return _is_filename_mod_list(str))
	
	var lists: Array = list_filenames.map(
		func(filename: String):
			return _path_to_name(filename))
	
	# Quick hack at the end so we can return a typed array
	var return_array: Array[String] = []
	return_array.assign(lists)
	return return_array


## Returns true if the given filename is a mod list by checking the extension
func _is_filename_mod_list(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile("\\.[mM][lL][iI]$")
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Converts a mod list file path to the name of the mod list
func _path_to_name(path: String) -> String:
	# TODO: duplicated in mod_list_editor
	# TODO: does not consider capitalisation
	path = path.trim_prefix(mod_list_path)
	path = path.trim_suffix(".mli")
	
	return path


# Signal connection
func _on_item_selected(index):
	if index < 0:
		return
	
	var mod_list_name = get_item_text(index)
	
	if mod_list_name == _last_selected:
		return
	
	_last_selected = mod_list_name
	mod_list_selected.emit(mod_list_name)
