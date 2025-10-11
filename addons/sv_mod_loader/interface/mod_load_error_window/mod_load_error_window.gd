extends Window
## Error window that displays after failing to load a mod. Provides options
## for recovery.

## Emitted when player chooses that mod loader should retry loading the mod.
signal retry
## Emitted when player chooses that mod loader should skip loading the failed
## mod and move on to the next mod.
signal skip


## Pass-through to Label. Passed through on ready and on set.
@export var error: ModLoadResult = ModLoadResult.new():
	get:
		return error
	set(value):
		error = value
		_update_error()


@onready var _error_message_label: Label = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/ErrorMessageLabel")


# Upd
func _ready():
	_update_error()


## Configure error message according to error
func _update_error() -> void:
	if (_error_message_label == null):
		return
	
	_error_message_label.text = error.get_message()
	# TODO: Also add a "retry and skip hash check" button if the error is a hash mismatch


# Signal connection
func _on_panel_container_resized() -> void:
	# Wrap contents does not shrink the window when children get smaller
	# so we have to do that ourselves
	# TODO: Somebody has reported this here: https://forum.godotengine.org/t/issue-with-wrap-controls-property-containing-window-node-wont-shrink-with-its-contents/81067
	# but it doesn't seem to have gotten much traction. Maybe worth making a
	# minimum reproducible example and raising as a bug?
	size.y = get_child(0).size.y


# Signal connection
func _on_retry_button_pressed() -> void:
	hide()
	retry.emit()


# Signal connection
func _on_skip_button_pressed() -> void:
	hide()
	skip.emit()


# Signal connection
func _on_abort_button_pressed() -> void:
	# Should have already saved before loading
	get_tree().quit()
