class_name Mod
extends Resource
## Mod configuration
##
## Resource storing a mod's configuration (i.e. whether it's enabled or not).
## Methods are provided for serialization to a Dictionary (JSON).

@export var filename: String
@export var enabled: bool
@export var required: bool = false


# Override
func _init():
	_reset()


## Serialize this mod to a JSON-compatible dictionary
func serialize() -> Dictionary:
	return {
		"filename": filename,
		"enabled": enabled,
		"required": required
	}


## Configure this mod by deserializing from a dictionary
func deserialize(dict: Dictionary) -> void:
	_reset()
	
	if dict.has("filename") and dict["filename"] is String:
		filename = dict["filename"]
	
	if dict.has("enabled") and dict["enabled"] is bool:
		enabled = dict["enabled"]
	
	if dict.has("required") and dict["required"] is bool:
		required = dict["required"]


## Reset to defaults
func _reset():
	filename = ""
	enabled = false
