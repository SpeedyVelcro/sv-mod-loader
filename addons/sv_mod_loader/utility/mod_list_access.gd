class_name ModListAccess
extends Object
## Class for saving and loading mod lists.
##
## Initialize using ModListAccess.new("<MY PATH>") where <MY PATH> is the fully
## qualified path to the directory where mod lists will be sored (e.g.
## "user://mod_lists")


## File extension for mod lists
const FILE_EXTENSION = ".mli"
## Regex to match mod list file extension. This must match FILE_EXTENSION,
## regardless of case, and nothing else.
const FILE_EXTENSION_REGEX = "\\.[mM][lL][iI]$"

## Path to directory where mod lists are stored
var _path: String

# Override
func _init(path: String) -> void:
	assert(path.is_absolute_path(), "Mod list path %s is not absolute" % path)
	
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	_path = path


## Saves the given mod list to a file
func save_file(mod_list: ModList) -> void:
	var abs_path: String = name_to_absolute_path(mod_list.name)

	var include_name: bool = false # Name is stored in file name instead
	var dict: Dictionary = mod_list.serialize(false)
	var json: String = JSON.stringify(dict, "\t")
	
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.WRITE)
	file.store_string(json)


## Loads and returns the mod list with the given name from a file
func load_file(mod_list_name: String) -> ModList:
	var abs_path: String = name_to_absolute_path(mod_list_name)
	var mod_list: ModList = ModList.new()
	mod_list.name = mod_list_name
	
	var file: FileAccess = FileAccess.open(abs_path, FileAccess.READ)
	
	if file == null:
		push_error("Failed to open file: " + abs_path)
	
	var json_string = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		push_error("Failed to parse JSON from file: " + abs_path)
	
	if not (json.data is Dictionary):
		push_warning("Mod list was not a dictionary.")
	
	var include_name: bool = false # We already set the name
	mod_list.deserialize(json.data, include_name)
	
	return mod_list


## Deletes from disk the mod list with the given name
func delete_file(mod_list_name: String) -> void:
	var abs_path: String = name_to_absolute_path(mod_list_name)
	
	var error = DirAccess.remove_absolute(abs_path)
	
	if error != OK:
		push_error("Error removing file: " + abs_path)


## Gets the names of all mod lists that have a file on disk
func get_names() -> Array[String]:
	var abs_paths: Array[String] = get_absolute_paths()
	
	var names: Array[String]
	names.assign(abs_paths.map(
			func(str: String) -> String:
					return absolute_path_to_name(str)
	))
	
	return names


## Gets the absolute paths of all saved mod lists
func get_absolute_paths() -> Array[String]:
	var filenames: Array[String] = get_filenames()
	
	var base_path: String = _path if _path.ends_with("/") else _path + "/"
	
	var mod_list_paths: Array[String]
	mod_list_paths.assign(filenames.map(
			func(str: String) -> String:
					return base_path + str
	))
	
	return mod_list_paths


## Gets the filenames of all saved mod lists
func get_filenames() -> Array[String]:
	var filenames: Array[String]
	filenames.assign(DirAccess.get_files_at(_path))
	
	var mod_list_filenames: Array[String] = filenames.filter(
			func(str: String) -> bool: return is_filename_mod_list(str)
	)
	
	return mod_list_filenames


## Converts a mod list name into the absolute path it would be saved to.
## Pushes an error if the name is an invalid filename.
func name_to_absolute_path(name: String) -> String:
	if not name.is_valid_filename():
		push_error("Name would be invalid as a filename: " + name)
	
	return PathHelper.filename_to_path(name + FILE_EXTENSION, _path)


## Converts an absolute path to the name of the mod list that would be saved to
## that path
func absolute_path_to_name(abs_path: String) -> String:
	if not is_absolute_path_valid(abs_path):
		push_error("Invalid mod list path: " + abs_path)
	
	var filename: String = abs_path.get_file()
	var name: String = filename.left(FILE_EXTENSION.length() * -1)
	
	return name


## Returns true if the given filename OR path is for a mod list
static func is_filename_mod_list(filename: String) -> bool:
	var regex = RegEx.new()
	regex.compile(FILE_EXTENSION_REGEX)
	
	var results = regex.search_all(filename)
	
	return results.size() > 0


## Returns true if the given absolute path points to a file in the mod list
## directory (and NOT in a subfolder of the mod directory)
## Does not check that the file is actually a mod list. For that use
## is_filename_mod_list
func is_absolute_path_file_in_path(test_path: String) -> bool:
	if not test_path.is_absolute_path():
		return false
	
	var base_path: String = _path if _path.ends_with("/") else _path + "/"
	
	# If there is nothing after the base path it can't be a file
	if not test_path.match(base_path + "?*"):
		return false
	
	var tail: String = test_path.trim_prefix(base_path)
	
	# If there are still slashes it must be in a subfolder
	if tail.contains("/"):
		return false
	
	return true


## Returns true if the given absolute path is a valid mod list path
func is_absolute_path_valid(test_path: String) -> bool:
	return is_filename_mod_list(test_path) and is_absolute_path_file_in_path(test_path)
