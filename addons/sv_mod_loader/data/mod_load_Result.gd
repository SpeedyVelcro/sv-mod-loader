class_name ModLoadResult
extends Resource
## Carries information about the success/failure to load a mod.

## Result of attempting to load mod
enum Status {SUCCESS, FAILURE}
## Error that was encountered
enum LoadError {NONE, FILE_NOT_FOUND, HASH_MISMATCH, FAILED_TO_LOAD}
## Type of hash that was used, if any
enum Hash {NONE, MD5, SHA_256}

## Result of attempting to load the mod
@export var status: Status = Status.SUCCESS
## Error that was encountered when loading the mod, if any
@export var error: LoadError = LoadError.NONE
## Absolute path to mod that was being attempted to load
@export var absolute_path: String = ""
## Hash type that was used, if error = HASH_MISMATCH
@export var hash_type: Hash = Hash.NONE
## Expected hash if error = HASH_MISMATCH
@export var expected_hash: String = ""
## Actual hash of file if error = HASH_MISMATCH
@export var actual_hash: String = ""
