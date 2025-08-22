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
## enabled (which is recommended).
@export var md5_hash: String = ""
