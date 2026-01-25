class_name ModLoaderUserSettingsAccess
extends Object
## Class for saving and loading user settings
##
## Initialize using ModLoaderUserSettingsAccess.new("<MY PATH>") where
## <MY PATH> is the fully qualified path to the user settings file.

## Path to user settings file
var _path: String


# Override
func _init(path: String) -> void:
	assert(path.is_absolute_path(), "Mod loader user settings path %s is not absolute" % path)
	
	var dir: String = PathHelper.file_path_to_containing_dir(path)
	
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	_path = path


## Saves the user settings to disk
func save_file(user_settings: ModLoaderUserSettings) -> void:
	var dict: Dictionary = user_settings.serialize()
	var json: String = JSON.stringify(dict, "\t")
	
	var file: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	file.store_string(json)


## Loads the user settings from disk if they exist; otherwise returns default
## settings.
func load_file() -> ModLoaderUserSettings:
	if not FileAccess.file_exists(_path):
		return ModLoaderUserSettings.new()
	
	var file: FileAccess = FileAccess.open(_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open file: " + _path)
	
	var json_string = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("Failed to parse JSON from file: " + _path)
	
	if not (json.data is Dictionary):
		push_warning("Mod loader user settings was not a dictionary.")
	
	var user_settings: ModLoaderUserSettings = ModLoaderUserSettings.new()
	user_settings.deserialize(json.data)
	
	return user_settings
