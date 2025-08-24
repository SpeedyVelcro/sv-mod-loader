class_name ModLoader
extends Node
## Loads mods and gets information about mods from disk.
##
## Initialize using ModLoader.new("<MY PATH>") where <MY_PATH> is the fully
## qualified path to the directory where mods will be stored, for example
## "user://mods".

## Emitted when a mod is loaded by this mod loader (i.e. the .pck is activated)
signal mod_loaded(mod: ActiveMod)

## Regex to match mod file extension
const FILE_EXTENSION_REGEX = "\\.[pP][cC][kK]$"

## Path where mods can be found.
var _path: String

# Override
func _init(path: String):
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	_path = path
	
	# Register with _load_order_tracker
	mod_loaded.connect(LoadOrderTracker._on_ModLoader_mod_loaded)


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


## Attempts to load the given required mod. Returns the result of loading.
func load_requirement(req: ModRequirement) -> ModLoadResult:
	var result = ModLoadResult.new()
	result.display_name = req.display_name
	result.absolute_path = ProjectSettings.globalize_path(req.path)
	
	# TODO: Verify hash
	
	if not FileAccess.file_exists(req.path):
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FILE_NOT_FOUND
		return result
	
	var load_success = ProjectSettings.load_resource_pack(req.path)
	
	if not load_success:
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FAILED_TO_LOAD
		return result
	
	mod_loaded.emit(ActiveMod.from_requirement(req))
	result.Status = ModLoadResult.Status.SUCCESS
	return result


## Attempts to load the given mod (regardless of whether it is enabled). Returns
## the result of loading.
func load_mod(mod: Mod) -> ModLoadResult:
	var result = ModLoadResult.new()
	result.display_name = mod.filename
	
	var path = filename_to_absolute_path(mod.filename)
	result.absolute_path = ProjectSettings.globalize_path(path)
	
	# TODO: Verify hash for trusted mods once they are implemented
	
	if not FileAccess.file_exists(path):
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FILE_NOT_FOUND
		return result
	
	var load_success = ProjectSettings.load_resource_pack(path)
	
	if not load_success:
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FAILED_TO_LOAD
		return result
	
	mod_loaded.emit(ActiveMod.from_mod(mod, path))
	result.Status = ModLoadResult.Status.SUCCESS
	return result


## Returns true if the given filename is for a mod
static func is_filename_mod(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile(FILE_EXTENSION_REGEX)
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Prepends the mod directory to the given filename to form an absolute path
func filename_to_absolute_path(filename: String) -> String:
	return PathHelper.filename_to_path(filename, _path)


## Called before destroy
func _destructor() -> void:
	if mod_loaded.is_connected(LoadOrderTracker._on_ModLoader_mod_loaded):
		mod_loaded.disconnect(LoadOrderTracker._on_ModLoader_mod_loaded)


# Override
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_destructor()
