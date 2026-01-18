class_name ModList
extends Resource
## User-configured mod load order
##
## This resource stores a user-configured mod load order. Methods are provided
## for serialization to a dictionary (JSON)

## Dictionary key for [member name]
const _NAME_KEY = "name"
## Dictionary key for [member loadOrder]
const _LOAD_ORDER_KEY = "loadOrder"

## Name of the mod list
@export var name: String
## Load order of mods
@export var load_order: Array[Mod]


# Override
func _init():
	_reset()


## Serialize this mod to a JSON-compatible dictionary. Optionally exclude name
## from the outputted dictionary (e.g. for cases when you store the name of the
## mod list on disk in the filename)
func serialize(include_name: bool = true) -> Dictionary:
	var dict: Dictionary = {}
	
	dict[_LOAD_ORDER_KEY] = _serialize_load_order()
	if include_name:
		dict[_NAME_KEY] = name
	
	return dict


## Removes all required mods from this list. This is useful for the case where
## you are loading/saving the mod but you do not want to load/save required mods
## because they are not supposed to be user-editable.
func prune_required() -> void:
	load_order = load_order.filter(func(mod: Mod): mod.required)


## Gets the mod list as an array of mods.
func to_array(only_enabled: bool = true) -> Array[Mod]:
	return load_order.filter(func(mod: Mod): return mod.enabled if only_enabled else true)


## Serialize the load order to an array
func _serialize_load_order() -> Array:
	var arr: Array = []
	for mod: Mod in load_order:
		arr.append(mod.serialize())
	
	return arr


## Configure this mod list by deserializing from a dictionary.
## If include_name is false, name is not changed from its current value.
func deserialize(dict: Dictionary, include_name: bool = true) -> void:
	_reset(include_name)
	
	if include_name and dict.has(_NAME_KEY) and dict[_NAME_KEY] is String:
		name = dict[_NAME_KEY]
	
	if dict.has(_LOAD_ORDER_KEY) and dict[_LOAD_ORDER_KEY] is Array:
		for mod in dict[_LOAD_ORDER_KEY]:
			load_order.append(Mod.new())
			if mod is Dictionary:
				load_order.back().deserialize(mod)


## Reset to defaults.
## If reset_name is false, name is not reset.
func _reset(reset_name: bool = true):
	if reset_name:
		name = ""
	load_order = []
