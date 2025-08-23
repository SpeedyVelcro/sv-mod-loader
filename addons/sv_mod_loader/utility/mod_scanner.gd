class_name ModLoader
extends Node
## Loads mods and gets information about mods from disk.
##
## Initialize using ModLoader.new("<MY PATH>") where <MY_PATH> is the fully
## qualified path to the directory where mods will be stored, for example
## "user://mods".

## Regex to match mod file extension
const FILE_EXTENSION_REGEX = "\\.[pP][cC][kK]$"

## Path where mods can be found.
var _path: String

# Override
func _init(path: String):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	_path = path


## Gets all mod filenames in the mod directory
func get_mod_filenames() -> Array[String]:
	var filenames: Array[String]
	filenames.assign(DirAccess.get_files_at(_path))
	
	var mod_filenames: Array[String] = filenames.filter(
			func(str: String) -> bool: return is_filename_mod(str)
	)
	
	return mod_filenames


## Gets all the mods in the mod directory, disabled by default
func get_mods(enabled = false) -> Array[Mod]:
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
func filename_to_absolute_path(filename: String) -> String:
	var base_path: String = _path if _path.ends_with("/") else _path + "/"
	
	return base_path + filename
