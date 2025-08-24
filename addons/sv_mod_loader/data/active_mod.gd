class_name ActiveMod
extends Resource
## Metadata about a currently active mod (i.e. the .pck has been loaded)

## Display name of the mod. May just be the same as the filename for user-set
## mods.
@export var display_name: String = ""
## Filename of the mod
@export var filename: String = ""
## Fully-qualified path to the mod
@export var path: String = ""
## MD5 hash of the mod
@export var md5_hash: String = ""
## SHA-256 hash of the mod
@export var sha256_hash: String = ""


## Creates active mod data from the given mod. Requires a path to the mod
## directory where the mod is stored, as mods don't carry this info themselves.
static func from_mod(mod: Mod, mod_dir: String) -> ActiveMod:
	var active_mod = ActiveMod.new()
	
	active_mod.display_name = mod.filename
	active_mod.filename = mod.filename
	active_mod.path = PathHelper.filename_to_path(mod.filename, mod_dir)
	active_mod.md5_hash = FileAccess.get_md5(active_mod.path)
	active_mod.sha256_hash = FileAccess.get_sha256(active_mod.path)
	
	return active_mod


## Creates active mod data from the given mod requirement.
static func from_requirement(req: ModRequirement) -> ActiveMod:
	var active_mod = ActiveMod.new()
	
	active_mod.display_name = req.display_name
	active_mod.filename = req.path.get_file()
	active_mod.path = req.path
	active_mod.md5_hash = FileAccess.get_md5(req.path)
	active_mod.sha256_hash = FileAccess.get_sha256(req.path)
	
	return active_mod
