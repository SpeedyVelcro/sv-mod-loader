class_name LoadResourcePackWrapper
extends Object
## Wraps calls to ProjectSettings.load_resource_pack
##
## Wrapper for ProjectSettings.load_resource_pack for easier mocking.

## Pass-through for ProjectSettings.load_resource_pack
func load_resource_pack(pack: String) -> bool:
	return ProjectSettings.load_resource_pack(pack)
