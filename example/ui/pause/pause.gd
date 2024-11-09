extends Control
## In-game pause menu
##
## In-game pause menu. Also handles keyboard input for pausing.

signal return_to_menu

## True if pausing is disabled (e.g. during game over)
var pause_disabled = false


## Toggles between paused and unpaused
func _toggle_pause() -> void:
	if pause_disabled:
		return
	
	get_tree().paused = !get_tree().paused
	
	visible = get_tree().paused


# Override
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


# Signal connection
func _on_resume_button_pressed() -> void:
	_toggle_pause()


# Signal connection
func _on_return_to_menu_button_pressed() -> void:
	return_to_menu.emit()
