extends Object


# This gets called by SV Mod Loader when the mod is loaded
func _init() -> void:
	var scene := BulletSpeedModifier.new()
	var tree: SceneTree = Engine.get_main_loop()
	
	tree.root.add_child(scene)
