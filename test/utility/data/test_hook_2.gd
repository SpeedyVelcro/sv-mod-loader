class_name TestHook2
extends Object

static var called: Signal = Signal()


func _init() -> void:
	called.emit()
