class_name Mod
extends Resource

@export var filename: String
@export var enabled: bool


# Override
func _init():
	_reset()


## Serialize this mod to a JSON-compatible dictionary
func serialize() -> Dictionary:
	return {
		"filename": filename,
		"enabled": enabled
	}


## Configure this mod by deserializing from a dictionary
func deserialize(dict: Dictionary) -> void:
	_reset()
	
	if dict.has("filename") and dict.filename is String:
		filename = dict.filename
	
	if dict.has("enabled") and dict.enabled is bool:
		enabled = dict.enabled


## Reset to defaults
func _reset():
	filename = ""
	enabled = false
