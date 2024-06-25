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
	var mod_array: Array[Mod] = ModScanner.get_mods()
	mod_array_editor.set_mod_array(mod_array)


## Save the currently selected mod list
func _save_current() -> void:
	ModListSaver.save_file(get_mod_list())


## Load the currently selected mod list
func _load_current() -> void:
	var mod_list: ModList = ModListSaver.load_file(mod_list_name)
	
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


## Configures according to given ModList
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
	pass # TODO


# Signal connection
func _on_option_button_item_selected(index) -> void:
	pass # TODO


func _on_new_mod_list_window_confirm(new_name, is_copy):
	if is_copy:
		_copy_mod_list(new_name)
	else:
		_new_mod_list(new_name)
