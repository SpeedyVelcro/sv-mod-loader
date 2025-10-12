class_name LoadOrderTracker
extends Object
## Class that tracks the currently loaded load order, as loaded by ModLoader.
##
## LoadOrderTracker is primarily useful for querying what mods are active once
## the game has launched. You can only add mods to the load order, not take
## away. This is because loading a .pck is an irreversible action. This class is
## singleton, because there can only ever be one currently loaded load order.

## Array containing all mods that have been loaded so far
static var _load_order: Array[ActiveMod]


## Get a copy of the current load order. This is a deep copy in order to
## prevent accidentally modifying the currently tracked info about the load
## order.
static func get_load_order() -> Array[ActiveMod]:
	return _load_order.map(func(mod: ActiveMod): return mod.duplicate(true))


# Signal connection
static func _on_ModLoader_mod_loaded(mod: ActiveMod):
	_load_order.append(mod)
