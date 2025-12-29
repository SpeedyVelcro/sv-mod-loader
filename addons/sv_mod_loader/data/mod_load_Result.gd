class_name ModLoadResult
extends Resource
## Carries information about the success/failure to load a mod.

## Result of attempting to load mod. Success, failure, or a general warning
## about the mod list.
enum Status {SUCCESS, WARNING, FAILURE}
## Error that was encountered
enum LoadError {NONE, LOADING_UNOFFICIAL_MODS, FILE_NOT_FOUND, HASH_MISMATCH, NO_HASH, FAILED_TO_LOAD}
## Type of hash that was used, if any
enum Hash {NONE, MD5, SHA_256}

## Result of attempting to load the mod
@export var status: Status = Status.SUCCESS
## Error that was encountered when loading the mod, if any
@export var error: LoadError = LoadError.NONE
## Display name of mod
@export var display_name: String = ""
## Absolute path to mod that was being attempted to load
@export var absolute_path: String = ""
## Hash type that was used, if error = HASH_MISMATCH
@export var hash_type: Hash = Hash.NONE
## Expected hash if error = HASH_MISMATCH
@export var expected_hash: String = ""
## Actual hash of file if error = HASH_MISMATCH
@export var actual_hash: String = ""


## Returns the name of the hash type
func get_hash_name() -> String:
	match hash_type:
		Hash.MD5:
			return "MD5"
		Hash.SHA_256:
			return "SHA-256"
	
	return "None"


## Gets a human-readable explanation of the error
func get_message() -> String:
	# TODO: Get from language files
	if status == Status.SUCCESS:
		return "Successfully loaded mod %s from path %s" % [display_name, absolute_path]
	
	var message
	
	if status == Status.FAILURE:
		message = "Failed to load mod %s from path %s" % [display_name, absolute_path]
		message += "\n\n"
	
	match error:
		LoadError.FILE_NOT_FOUND:
			message += "File not found."
		LoadError.HASH_MISMATCH:
			message += "Mod is enabled for hash-checking, but the mod's hash
					differs from the expected hash. The mod may have been
					tampered with.
					
					Hash type: %s
					
					Expected hash: %s
					
					Actual hash: %s" % [get_hash_name(), expected_hash, actual_hash]
		LoadError.NO_HASH:
			message += "Developer (NOT the mod author) has enabled hash checking
					but no expected hash was provided for the mod."
		LoadError.FAILED_TO_LOAD:
			message += "Error while loading file."
		LoadError.LOADING_UNOFFICIAL_MODS:
			message += "WARNING: You are attempting to load unofficial mods.
					
					Mods have full access to the underlying game engine and are
					capable of executing arbitrary code. RUNNING MODS FROM
					UNTRUSTED SOURCES CAN BE EXTREMELY DANGEROUS. You should only
					run mods you completely trust and know are safe.
					
					Do you trust the mods you are attempting to load, and wish
					to continue?"
	
	return message
