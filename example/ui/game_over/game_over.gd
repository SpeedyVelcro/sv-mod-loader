extends Control

signal retry
signal return_to_menu


func _on_retry_button_pressed() -> void:
	retry.emit()


func _on_return_to_menu_button_pressed() -> void:
	return_to_menu.emit()
