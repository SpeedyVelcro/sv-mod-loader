class_name ModRequirement
extends Resource
## Mod Requirement
##
## Specifies information about a mod that is required to launch the game.

## Fully qualified path (i.e. including "res://" or "user://") to the location
## of the mod file.
@export var path: String = ""
## Display name, if this differs from the filename.
@export var display_name: String = ""
## MD5 hash of the file. Used to verify integrity, if that functionality is
## enabled (which is recommended). If you have integrity verification enabled,
## you must provide one of the MD5 or SHA-256 hashes. If you provide the SHA-256
## hash, that will be used instead as it's more secure.
@export var md5_hash: String = ""
## SHA-256 hash of the file. Used to verify integrity, if that functionality is
## enabled (which is recommended). If you have integrity verification enabled,
## you must provide one of the MD5 or SHA-256 hashes. The SHA-256 hash is
## preferred and will be used instead of the MD5 hash if both are provided, as
## SHA-256 is more secure.
@export var sha256_hash: String = ""
