class_name Mod
extends Resource
## Mod configuration
##
## Resource storing a mod's configuration (i.e. whether it's enabled or not).
## Methods are provided for serialization to a Dictionary (JSON).

## Dictionary key for [member filename]
const _FILENAME_KEY = "filename"
## Dictionary key for [member enabled]
const _ENABLED_KEY = "enabled"
## Dictionary key for [member required]
const _REQUIRED_KEY = "required"

## Filename of mod
@export var filename: String
## Whether the mod is configured to load
@export var enabled: bool
## Whether the mod is required to run the game
@export var required: bool = false


# Override
func _init():
	_reset()


## Serialize this mod to a JSON-compatible dictionary
func serialize() -> Dictionary:
	return {
		_FILENAME_KEY: filename,
		_ENABLED_KEY: enabled,
		_REQUIRED_KEY: required
	}


## Configure this mod by deserializing from a dictionary
func deserialize(dict: Dictionary) -> void:
	_reset()
	
	if dict.has(_FILENAME_KEY) and dict[_FILENAME_KEY] is String:
		filename = dict[_FILENAME_KEY]
	
	if dict.has(_ENABLED_KEY) and dict[_ENABLED_KEY] is bool:
		enabled = dict[_ENABLED_KEY]
	
	if dict.has(_REQUIRED_KEY) and dict[_REQUIRED_KEY] is bool:
		required = dict[_REQUIRED_KEY]


## Reset to defaults
func _reset():
	filename = ""
	enabled = false
