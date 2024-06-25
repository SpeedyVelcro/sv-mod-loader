class_name ModScanner
extends Node
## Gets information about mods on disk
##
## ModScanner provides static functions and variables for getting information
## about which mods are in the mod directory.
# TODO: Confirm mod directory exists

## Regex to match mod file extension
const FILE_EXTENSION_REGEX = "\\.[pP][cC][kK]$"

## Path where mods can be found
static var path: String = "user://mods"


## Gets all mod filenames in the mod directory
static func get_mod_filenames() -> Array[String]:
	_set_up_path()
	
	var filenames: Array[String] = DirAccess.get_files_at(path)
	
	var mod_filenames: Array[String] = filenames.filter(
			func(str: String) -> bool: return is_filename_mod(str)
	)
	
	return mod_filenames


## Gets all the mods in the mod directory, disabled by default
static func get_mods(enabled = false) -> Array[Mod]:
	var mod_filenames: Array[String] = get_mod_filenames()
	
	var mods: Array[Mod] = mod_filenames.map(
			func(str: String) -> Mod:
					var mod: Mod = Mod.new()
					mod.filename = str
					mod.enabled = enabled
					return mod
	)
	
	return mods


## Returns true if the given filename is for a mod
static func is_filename_mod(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile(FILE_EXTENSION_REGEX)
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Create configured path if it doesn't already exist
static func _set_up_path():
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
