class_name TestHook1
extends Object

static var called_times: int = 0


func _init() -> void:
	called_times += 1
