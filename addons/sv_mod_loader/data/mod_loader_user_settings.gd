class_name ModLoaderUserSettings
extends Resource
## User settings for SV Mod Loader
##
## Resource carrying user settings for configuring SV Mod Loader. Stored on disk
## as JSON, so methods are provided for serialization and deserialization.

## Serialize these settings to a JSON-compatible dictionary
func serialize() -> Dictionary:
	return {
		# TODO
	}


## Populate settings values by deserializing from a dictionary
func deserialize(dict: Dictionary) -> void:
	_reset()
	
	# TODO


## Reset to defaults
func _reset():
	pass # TODO
