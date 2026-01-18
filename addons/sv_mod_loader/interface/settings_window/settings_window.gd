extends Window
## Window for configuring mod loader user settings.
##
## Note that this scene does not handle saving and loading; it just modifies the
## user settings you inject. Consumers need to handle saving and loading after
## the fact (e.g. by connecting to the)

## Emitted when the user has finished editing (i.e. they have closed the window)
signal finished_editing

## User settings for this settings window to configure. Pass in user settings
## here (NOT a copy), and the settings window will make changes to it according
## to what the user changes in the interface
@export var user_settings: ModLoaderUserSettings:
	get:
		return user_settings
	set(value):
		user_settings = value
		_update_control_settings()

@onready var _ignore_untrusted_warning_check_box: CheckBox = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/IgnoreUntrustedWarningCheckBox")


## Signal that the user has finished editing, and close the window.
func finish_and_close() -> void:
	finished_editing.emit()
	hide()


# Override
func _ready() -> void:
	pass # TODO


## Updates controls according to settings
func _update_control_settings():
	if not is_instance_valid(user_settings):
		return
	
	_ignore_untrusted_warning_check_box.set_pressed_no_signal(
			user_settings.hide_untrusted_warning)


# Signal connection
func _on_ignore_untrusted_warning_check_box_toggled(toggled_on: bool) -> void:
	if not is_instance_valid(user_settings):
		return
	
	user_settings.hide_untrusted_warning = toggled_on


# Signal connection
func _on_close_button_pressed() -> void:
	finish_and_close()
