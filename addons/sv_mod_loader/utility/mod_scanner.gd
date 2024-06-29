class_name ModScanner
extends Node
## Gets information about mods on disk
##
## ModScanner provides static functions and variables for getting information
## about which mods are in the mod directory.
# TODO: Confirm mod directory exists

## Regex to match mod file extension
const FILE_EXTENSION_REGEX = "\\.[pP][cC][kK]$"

## Path where mods can be found. Should be an absolute path to a directory. Can
## include or not include a trailing forward-slash, does not matter. Directory
## will be created recursively if it doesn't already exist.
static var path: String = "user://mods"


## Gets all mod filenames in the mod directory
static func get_mod_filenames() -> Array[String]:
	_set_up_path()
	
	var filenames: Array[String]
	filenames.assign(DirAccess.get_files_at(path))
	
	var mod_filenames: Array[String] = filenames.filter(
			func(str: String) -> bool: return is_filename_mod(str)
	)
	
	return mod_filenames


## Gets all the mods in the mod directory, disabled by default
static func get_mods(enabled = false) -> Array[Mod]:
	var mod_filenames: Array[String] = get_mod_filenames()
	
	var mods: Array[Mod]
	mods.assign(mod_filenames.map(
			func(str: String) -> Mod:
					var mod: Mod = Mod.new()
					mod.filename = str
					mod.enabled = enabled
					return mod
	))
	
	return mods


## Returns true if the given filename is for a mod
static func is_filename_mod(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile(FILE_EXTENSION_REGEX)
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Prepends the mod directory to the given filename to form an absolute path
static func filename_to_absolute_path(filename: String) -> String:
	var base_path: String = path if path.ends_with("/") else path + "/"
	
	return base_path + filename


## Create configured path if it doesn't already exist
static func _set_up_path():
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
