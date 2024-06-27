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
## Popup to confirm deletion
@export var delete_mod_list_window: Window
## OptionButton for selecting mod lists
@export var option_button: OptionButton

## Default mod list name
const DEFAULT_MOD_LIST_NAME = "Default"

## Name of the currently selected mod list
var mod_list_name: String = ""

# Override
func _ready():
	# Scan for mods
	var mod_array: Array[Mod] = ModScanner.get_mods()
	mod_array_editor.set_mod_array(mod_array)
	
	# Select starting mod list
	_create_default_if_no_mod_lists()
	
	var mod_list_names: Array[String] = ModListSaver.get_names()
	var mod_list = ModListSaver.load_file(mod_list_names.front()) # TODO: Select last selected mod list according to config file
	_set_mod_list(mod_list)
	
	# Set up OptionButton
	_populate_option_button(mod_list_name)


## Populates OptionButton with mod lists.
## select_name sets which mod list is to be selected after population. Empty
## string means none selected
func _populate_option_button(select_name: String = ""):
	option_button.select(-1)
	option_button.clear()
	
	var mod_list_names: Array[String] = ModListSaver.get_names()
	
	for i in mod_list_names.size():
		option_button.add_item(mod_list_names[i], i)
	
	if select_name == "":
		return
	
	var select_index: int = mod_list_names.find(select_name)
	option_button.select(select_index)


## Save the currently selected mod list
func _save_current() -> void:
	ModListSaver.save_file(get_mod_list())


## Load the currently selected mod list
func _load_current() -> void:
	var mod_list: ModList = ModListSaver.load_file(mod_list_name)
	
	_set_mod_list(mod_list)


## Delete currently selected mod list
func _delete_current() -> void:
	ModListSaver.save_file(get_mod_list()) # To ensure there is something to delete on disk
	ModListSaver.delete_file(mod_list_name)
	
	_create_default_if_no_mod_lists()
	
	# TODO: More advanced selection where we default to whatever mod list was
	# immediately after or before the one we just deleted, rather than just thed
	# first in the list
	var mod_list_names: Array[String] = ModListSaver.get_names()
	var mod_list: ModList = ModListSaver.load_file(mod_list_names.front())
	_set_mod_list(mod_list)


## Select a mod list. Saves the current mod list and loads the selected one.
func _select(new_name: String) -> void:
	_save_current()
	mod_list_name = new_name
	_load_current()


## Gets the current configuration as a ModList
func get_mod_list() -> ModList:
	var mod_array: Array[Mod] = mod_array_editor.get_mod_array()
	var mod_list: ModList = ModList.new()
	
	mod_list.name = mod_list_name
	mod_list.load_order = mod_array_editor.get_mod_array()
	
	return mod_list


## Gets a configuration for the default ModList
func _get_default_mod_list() -> ModList:
	var mod_list: ModList = ModList.new()
	mod_list.name = DEFAULT_MOD_LIST_NAME
	return mod_list


## Creates the default mod list if no mod lists exist
func _create_default_if_no_mod_lists() -> void:
	var mod_list_names: Array[String] = ModListSaver.get_names()
	
	if mod_list_names.size() <= 0:
		var default: ModList = _get_default_mod_list()
		ModListSaver.save_file(default)


## Configures according to given ModList. This discards any existing mod list
func _set_mod_list(mod_list: ModList) -> void:
	mod_list_name = mod_list.name
	mod_array_editor.update_mod_array(mod_list.load_order)


## Configures as a new ModList with the given name
func _new_mod_list(new_name: String) -> void:
	var mod_list: ModList = ModList.new()
	mod_list.name = new_name
	ModListSaver.save_file(mod_list)
	
	_select(mod_list.name)


## Configures as a new ModList with the same name as the current one
func _copy_mod_list(new_name: String) -> void:
	var mod_list: ModList = get_mod_list()
	mod_list.name = new_name
	ModListSaver.save_file(mod_list)
	
	_select(mod_list.name)


# Signal connection
func _on_new_button_pressed() -> void:
	new_mod_list_window.popup_centered()


# Signal connection
func _on_delete_button_pressed() -> void:
	delete_mod_list_window.popup_centered()


# Signal connection
func _on_option_button_item_selected(index) -> void:
	var selected_name: String = option_button.get_item_text(index)
	_select(selected_name)


# Signal connection
func _on_new_mod_list_window_confirm(new_name, is_copy):
	if is_copy:
		_copy_mod_list(new_name)
	else:
		_new_mod_list(new_name)


# Signal connection
func _on_delete_confirm_button_pressed():
	_delete_current()
	delete_mod_list_window.hide()


# Signal connection
func _on_delete_cancel_button_pressed():
	delete_mod_list_window.hide()
