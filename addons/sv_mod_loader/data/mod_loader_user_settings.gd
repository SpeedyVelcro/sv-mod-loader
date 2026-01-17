class_name ModLoaderUserSettings
extends Resource
## User settings for SV Mod Loader
##
## Resource carrying user settings for configuring SV Mod Loader. Stored on disk
## as JSON, so methods are provided for serialization and deserialization.

## Dictionary key for [member hide_untrusted_warning]
const _HIDE_UNTRUSTED_WARNING_KEY = "hideUntrustedWarning"

## Hide warning when loading untrusted mods
@export var hide_untrusted_warning: bool


## Serialize these settings to a JSON-compatible dictionary
func serialize() -> Dictionary:
	return {
		_HIDE_UNTRUSTED_WARNING_KEY: hide_untrusted_warning
	}


## Populate settings values by deserializing from a dictionary
func deserialize(dict: Dictionary) -> void:
	_reset()
	
	if dict.has(_HIDE_UNTRUSTED_WARNING_KEY) and dict[_HIDE_UNTRUSTED_WARNING_KEY] is bool:
		hide_untrusted_warning = dict[_HIDE_UNTRUSTED_WARNING_KEY]


## Reset to defaults
func _reset():
	hide_untrusted_warning = false
