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
	
	var dir: String = path.rsplit("/", true, 1)[0]
	
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	_path = path


## Saves the user settings to disk
func save_file() -> void:
	pass # TODO


## Loads the user settings from disk if they exist; otherwise returns default
## settings.
func load_file(mod_list_name: String) -> ModLoaderUserSettings:
	return null # TODO
