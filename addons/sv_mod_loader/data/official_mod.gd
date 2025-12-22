extends Node
## Official Mod
##
## Specifies information about an official mod, or a mod otherwise trusted by
## the authors of the game. This mod can be loaded without prompting a safety
## warning.

## Filename of the mod. Only the filename; should not include the rest of the
## path.
@export var filename: String = ""
## MD5 hash of the file. You must provide one of the MD5 or SHA-256 hashes. If
## both are provided, both will be checked.
@export var md5_hash: String = ""
## SHA-256 hash of the file. You must provide one of the MD5 or SHA-256 hashes.
## The SHA-256 hash is preferred, as SHA-256 is more secure. If both are
## provided, both will be checked.
@export var sha256_hash: String = ""
