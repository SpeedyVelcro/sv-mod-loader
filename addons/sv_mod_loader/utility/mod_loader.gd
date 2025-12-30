class_name ModLoader
extends Node
## Loads mods and gets information about mods from disk.
##
## A class that loads mod pcks. This class is stateful, storing information
## about current progress loading mods, and therefore allowing the consumer
## to recover from any errors and continue loading mods. This is intended to
## allow the implementation of dialogs for user intervention.
##
## Initialize using ModLoader.new("<MY PATH>") where <MY_PATH> is the fully
## qualified path to the directory where mods will be stored, for example
## "user://mods".

## Emitted when a mod is loaded by this mod loader (i.e. the .pck is activated)
signal mod_loaded(mod: ActiveMod)
## Emitted when the entire mod list has finished loading
signal finished

## Regex to match mod file extension
const FILE_EXTENSION_REGEX = "\\.[pP][cC][kK]$"

## Path where mods can be found.
var _path: String
## Required mods that are queued for loading
var _queued_required_mods: Array[ModRequirement] = []
## Mods that are queued for loading
var _queued_mods: Array[Mod] = []
## True if current required mods queue should be verified
var _verify_required: bool = false
## Official (trusted) mods that won't raise a warning if their checksums match
var _official_mods: Array[OfficialMod] = []
## Cumulative results of mod loading. When a mod is retried, it may appear
## multiple times.
var _results: Array[ModLoadResult] = []

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


## Loads all of the given mod requirements, then the entire mod list. Returns
## true if successful. Returns the result of each load as an array. If an error
## is encountered loading a mod, the function aborts and returns all results
## so far including the error.
## 
## ModLoader remembers its progress and all mods are still queued (including the
## one that has failed, which you may want to skip). Therefore after an error
## you can take action to recover, and continue loading the rest of the mods
## (usually this would involve prompting the user to ask them what to do).
func load_all(mods: Array[Mod], required_mods: Array[ModRequirement] = [], verify_required: bool = true, official_mods: Array[OfficialMod] = []) -> Array[ModLoadResult]:
	_results = []
	_queued_required_mods = required_mods
	_queued_mods = mods
	_verify_required = verify_required
	_official_mods = official_mods
	
	var _is_not_official_mod = func(m: Mod):
		return not _official_mods.any(func(o: OfficialMod): return o.filename == m.filename)
	
	if _queued_mods.any(_is_not_official_mod):
		var result = ModLoadResult.new()
		result.status = ModLoadResult.Status.WARNING
		result.error = ModLoadResult.LoadError.LOADING_UNOFFICIAL_MODS
		
		return [result]
	
	return _continue_load_all()


## Dequeue the first queued mod from loading. Useful after load_all() has
## aborted due to an error, so that you don't attempt to load the offending mod.
## Then continues loading all the mods.
func skip_next_and_continue() -> Array[ModLoadResult]:
	if not _queued_required_mods.is_empty():
		_queued_required_mods.pop_front()
	elif not _queued_mods.is_empty():
		_queued_mods.pop_front()
	
	return _continue_load_all()


## Load the first queued mod, skipping hash verification, then continue.
## 
## This is useful after a load_all() has aborted due to a hash mismatch, if you
## want to recover by ignoring the error. Note that this may incur security
## risks. 
func force_load_next_and_continue() -> Array[ModLoadResult]:
	var force = true
	_load_next(force)
	
	return _continue_load_all()


## Retry loading the first queued mod. Useful if the user has fixed something
## in the background (or if the error was a one-off warning). Then continues
## loading all the mods.
func retry_next_and_continue() -> Array[ModLoadResult]:
	return _continue_load_all()


## Attempts to load the given required mod. Returns the result of loading.
func load_requirement(req: ModRequirement, verify_integrity: bool) -> ModLoadResult:
	var result = ModLoadResult.new()
	result.display_name = req.display_name
	result.absolute_path = ProjectSettings.globalize_path(req.path)
	
	if not FileAccess.file_exists(req.path):
		result.status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FILE_NOT_FOUND
		return result
	
	# TODO: repetition from load_mod
	if verify_integrity and req.md5_hash.is_empty() and req.sha256_hash.is_empty():
		result.status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.NO_HASH
		return result
	
	if verify_integrity and not req.sha256_hash.is_empty():
		var hash = FileAccess.get_sha256(req.path)
		if hash != req.sha256_hash:
			result.status = ModLoadResult.Status.FAILURE
			result.error = ModLoadResult.LoadError.HASH_MISMATCH
			result.hash_type = ModLoadResult.Hash.SHA_256
			result.expected_hash = req.sha256_hash
			result.actual_hash = hash
			return result
	
	if verify_integrity and not req.md5_hash.is_empty():
		var hash = FileAccess.get_md5(req.path)
		if hash != req.md5_hash:
			result.status = ModLoadResult.Status.FAILURE
			result.error = ModLoadResult.LoadError.HASH_MISMATCH
			result.hash_type = ModLoadResult.Hash.MD5
			result.expected_hash = req.md5_hash
			result.actual_hash = hash
			return result
	
	var load_success = ProjectSettings.load_resource_pack(req.path)
	
	if not load_success:
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FAILED_TO_LOAD
		return result
	
	mod_loaded.emit(ActiveMod.from_requirement(req))
	result.status = ModLoadResult.Status.SUCCESS
	return result


## Attempts to load the given mod (regardless of whether it is enabled). Returns
## the result of loading.
func load_mod(mod: Mod, ignore_official_mod_checksum: bool) -> ModLoadResult:
	var result = ModLoadResult.new()
	result.display_name = mod.filename
	
	var path = filename_to_absolute_path(mod.filename)
	result.absolute_path = ProjectSettings.globalize_path(path)
	
	if not FileAccess.file_exists(path):
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FILE_NOT_FOUND
		return result
	
	var official_mod: OfficialMod = null
	var filtered = _official_mods.filter(func(m): return m.filename == mod.filename)
	official_mod = null if filtered.is_empty() else filtered.front()
	
	# TODO: repetition from load_requirement
	if official_mod and official_mod.md5_hash.is_empty() and official_mod.sha256_hash.is_empty():
		result.status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.NO_HASH
		return result
	
	if official_mod and not official_mod.sha256_hash.is_empty():
		var hash = FileAccess.get_sha256(path)
		if hash != official_mod.sha256_hash:
			result.status = ModLoadResult.Status.FAILURE
			result.error = ModLoadResult.LoadError.HASH_MISMATCH
			result.hash_type = ModLoadResult.Hash.SHA_256
			result.expected_hash = official_mod.sha256_hash
			result.actual_hash = hash
			return result
	
	if official_mod and not official_mod.md5_hash.is_empty():
		var hash = FileAccess.get_md5(official_mod.path)
		if hash != official_mod.md5_hash:
			result.status = ModLoadResult.Status.FAILURE
			result.error = ModLoadResult.LoadError.HASH_MISMATCH
			result.hash_type = ModLoadResult.Hash.MD5
			result.expected_hash = official_mod.md5_hash
			result.actual_hash = hash
			return result
	
	var load_success = ProjectSettings.load_resource_pack(path)
	
	if not load_success:
		result.Status = ModLoadResult.Status.FAILURE
		result.error = ModLoadResult.LoadError.FAILED_TO_LOAD
		return result
	
	mod_loaded.emit(ActiveMod.from_mod(mod, path))
	result.status = ModLoadResult.Status.SUCCESS
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


## Continues a previously aborted load_all() attempt
func _continue_load_all() -> Array[ModLoadResult]:
	while (not _queued_required_mods.is_empty()) or (not _queued_mods.is_empty()):
		if _load_next():
			continue
		
		return _results
	
	if _results.is_empty() or _results.back().status == ModLoadResult.Status.SUCCESS:
		finished.emit()
	
	return _results

## Load the next queued mod. Returns true and dequeues the mod if successful.
## Also returns true if there are no queued mods to load.
func _load_next(force: bool = false) -> bool:
	if not _queued_required_mods.is_empty():
		var result = load_requirement(_queued_required_mods.front(), false if force else _verify_required)
		_results.append(result)
		if result.status == ModLoadResult.Status.FAILURE:
			return false
		_queued_required_mods.pop_front()
		return true
	
	if not _queued_mods.is_empty():
		var result = load_mod(_queued_mods.front(), force)
		_results.append(result)
		if result.status == ModLoadResult.Status.FAILURE:
			return false
		_queued_mods.pop_front()
		return true
	
	return true


## Called before destroy
func _destructor() -> void:
	if mod_loaded.is_connected(LoadOrderTracker._on_ModLoader_mod_loaded):
		mod_loaded.disconnect(LoadOrderTracker._on_ModLoader_mod_loaded)


# Override
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_destructor()
