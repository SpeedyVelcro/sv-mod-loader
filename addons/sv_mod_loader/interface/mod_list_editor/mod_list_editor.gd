extends VBoxContainer
## UI Element for editing, selecting, saving and loading mod lists
##
## UI Element where you can choose and edit a mod list. You can also delete
## mod lists and create new ones.

## File path where mod lists are stored.
@export var mod_list_path: String = "user://mod_lists"
## File path where mods are stored.
@export var mod_path: String = "user://mods"
## Whether the mod list should populate on ready based on the exported
## properties. You may set this to false if you wish to set them programatically
## first.
@export var populate_on_ready: bool = true

@export_group("Required Mods")
## Mods that are required to launch the game. They will be automatically
## enabled, and users will not be able to disable them.
@export var required_mods: Array[ModRequirement] = []
## Whether to verify the integrity of the required mods before launching the
## game. This uses MD5 hashes. It is strongly recommended that you keep this
## set to TRUE, as disabling this will put users at risk of attacks from
## malicious actors by replacing your required mods.
@export var verify_required_mods: bool

## Default mod list name
const DEFAULT_MOD_LIST_NAME = "Default"

## Name of the currently selected mod list
var mod_list_name: String = ""

## Child load order editor
@onready var _mod_array_editor: Node = get_node("ModArrayEditor")
## Popup for new mod list
@onready var _new_mod_list_window: Window = get_node("NewModListWindow")
## Popup to confirm deletion
@onready var _delete_mod_list_window: Window = get_node("DeleteModListWindow")
## OptionButton for selecting mod lists
@onready var _option_button: OptionButton = get_node("OptionButton")

## Save the currently selected mod list
func save_current() -> void:
	ModListAccess.new(mod_list_path).save_file(get_mod_list())


## Populate the mod list editor based on the user's files. Also "populates" the
## new mod list window with the mod list path.
func populate() -> void:
	_new_mod_list_window.mod_list_path = mod_list_path
	
	_mod_array_editor.set_mod_requirements(required_mods)
	
	# Scan for mods
	var mod_array: Array[Mod] = ModLoader.new(mod_path).get_mods()
	# Get rid of required mods, since they'll be at the beginning and force-enabled anyway
	# TODO: that funky rsplit at the end to get the filename from path should probably be moved to PathHelper (also it might cause a crash if the path is malformed)
	mod_array = mod_array.filter(func (mod: Mod): return not required_mods.any(func(req: ModRequirement): return mod.filename == req.path.rsplit("/", true, 1)[1]))
	_mod_array_editor.set_mod_array(mod_array)
	
	# Select starting mod list
	_create_default_if_no_mod_lists()
	
	var mod_list_access = ModListAccess.new(mod_list_path)
	var mod_list_names: Array[String] = mod_list_access.get_names()
	var mod_list = mod_list_access.load_file(mod_list_names.front()) # TODO: Select last selected mod list according to config file
	_set_mod_list(mod_list)
	
	# Set up OptionButton
	_populate_option_button(mod_list_name)


## Gets the current configuration as a ModList
func get_mod_list() -> ModList:
	var mod_array: Array[Mod] = _mod_array_editor.get_mod_array()
	var mod_list: ModList = ModList.new()
	
	mod_list.name = mod_list_name
	mod_list.load_order = _mod_array_editor.get_mod_array()
	
	return mod_list


# Override
func _ready():
	if (populate_on_ready):
		populate()


# Override
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			save_current()


## Populates OptionButton with mod lists.
## select_name sets which mod list is to be selected after population. Empty
## string means none selected
func _populate_option_button(select_name: String = ""):
	_option_button.select(-1)
	_option_button.clear()
	
	var mod_list_names: Array[String] = ModListAccess.new(mod_list_path).get_names()
	
	for i in mod_list_names.size():
		_option_button.add_item(mod_list_names[i], i)
	
	if select_name == "":
		return
	
	var select_index: int = mod_list_names.find(select_name)
	_option_button.select(select_index)


## Load the currently selected mod list
func _load_current() -> void:
	var mod_list: ModList = ModListAccess.new(mod_list_path).load_file(mod_list_name)
	
	_set_mod_list(mod_list)


## Delete currently selected mod list
func _delete_current() -> void:
	var mod_list_access = ModListAccess.new(mod_list_path)
	
	mod_list_access.save_file(get_mod_list()) # To ensure there is something to delete on disk
	mod_list_access.delete_file(mod_list_name)
	
	_create_default_if_no_mod_lists()
	
	# TODO: More advanced selection where we default to whatever mod list was
	# immediately after or before the one we just deleted, rather than just the
	# first in the list
	var mod_list_names: Array[String] = mod_list_access.get_names()
	var mod_list: ModList = mod_list_access.load_file(mod_list_names.front())
	_set_mod_list(mod_list)
	
	_populate_option_button(mod_list_name)


## Select a mod list. Saves the current mod list and loads the selected one.
func _select(new_name: String) -> void:
	save_current()
	mod_list_name = new_name
	_load_current()


## Gets a configuration for the default ModList
func _get_default_mod_list() -> ModList:
	var mod_list: ModList = ModList.new()
	mod_list.name = DEFAULT_MOD_LIST_NAME
	return mod_list


## Creates the default mod list if no mod lists exist
func _create_default_if_no_mod_lists() -> void:
	var mod_list_access = ModListAccess.new(mod_list_path)
	
	var mod_list_names: Array[String] = mod_list_access.get_names()
	
	if mod_list_names.size() <= 0:
		var default: ModList = _get_default_mod_list()
		mod_list_access.save_file(default)


## Configures according to given ModList. This discards any existing mod list
func _set_mod_list(mod_list: ModList) -> void:
	mod_list_name = mod_list.name
	_mod_array_editor.update_mod_array(mod_list.load_order)


## Configures as a new ModList with the given name
func _new_mod_list(new_name: String) -> void:
	var mod_list: ModList = ModList.new()
	mod_list.name = new_name
	ModListAccess.new(mod_list_path).save_file(mod_list)
	
	_select(mod_list.name)
	
	_populate_option_button(mod_list_name)


## Configures as a new ModList with the same name as the current one
func _copy_mod_list(new_name: String) -> void:
	var mod_list: ModList = get_mod_list()
	mod_list.name = new_name
	ModListAccess.new(mod_list_path).save_file(mod_list)
	
	_select(mod_list.name)
	
	_populate_option_button(mod_list_name)


# Signal connection
func _on_new_button_pressed() -> void:
	_new_mod_list_window.popup_centered()


# Signal connection
func _on_delete_button_pressed() -> void:
	_delete_mod_list_window.popup_centered()


# Signal connection
func _on_option_button_item_selected(index) -> void:
	var selected_name: String = _option_button.get_item_text(index)
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
	_delete_mod_list_window.hide()


# Signal connection
func _on_delete_cancel_button_pressed():
	_delete_mod_list_window.hide()
