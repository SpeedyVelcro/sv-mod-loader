class_name ModList
extends Resource
## User-configured mod load order
##
## This resource stores a user-configured mod load order. Methods are provided
## for serialization to a dictionary (JSON)

@export var name: String
@export var load_order: Array[Mod]


# Override
func _init():
	_reset()


## Serialize this mod to a JSON-compatible dictionary. Optionally exclude name
## from the outputted dictionary (e.g. for cases when you store the name of the
## mod list on disk in the filename)
func serialize(include_name: bool = true) -> Dictionary:
	var dict: Dictionary = {}
	
	dict["modList"] = load_order
	if include_name:
		dict["name"] = name
	
	return dict


## Configure this mod list by deserializing from a dictionary.
## If include_name is false, name is not changed from its current value.
func deserialize(dict: Dictionary, include_name: bool = true) -> void:
	_reset()
	
	if dict.has("name") and dict["name"] is String:
		name = dict["name"]
	
	if dict.has("loadOrder") and dict["loadOrder"] is Array:
		for mod in dict["loadOrder"]:
			load_order.append(Mod.new())
			if mod is Dictionary:
				load_order.back().deserialize(mod)


## Reset to defaults.
## If reset_name is false, name is not reset.
func _reset(reset_name: bool = true):
	if reset_name:
		name = ""
	load_order = []
