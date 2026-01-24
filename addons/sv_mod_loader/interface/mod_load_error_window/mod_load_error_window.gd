extends Window
## Error window that displays after failing to load a mod. Provides options
## for recovery.

## Emitted when the player chooses to force loading the mod anyway, skipping
## hash checks.
signal force_load
## Emitted when player chooses that mod loader should retry loading the mod.
signal retry
## Emitted when player chooses that mod loader should skip loading the failed
## mod and move on to the next mod.
signal skip


## Pass-through to Label. Passed through on ready and on set.
@export var error_message: String = "":
	get:
		return error_message
	set(value):
		error_message = value
		_update_error_message()
## Allow forcing loading the next mod by skipping hash check.
@export var can_force_load: bool = false:
	get:
		return can_force_load
	set(value):
		can_force_load = value
		_update_can_force_load()
## Allow cancelling without aborting. Should only be allowed when no mods have
## been loaded yet, because loading mods is an irreversible action.
@export var can_cancel: bool = false:
	get:
		return can_cancel
	set(value):
		can_cancel = value
		_update_can_cancel()
## Allow skipping the next mod then continuing. A good reason to disable would
## be if the error doesn't pertain to a specific mod.
@export var can_skip: bool = false:
	get:
		return can_skip
	set(value):
		can_skip = value
		_update_can_skip()
## True if the retry button should read "continue" instead. This is preferred
## when trying to load a mod hasn't actually happened yet (e.g. for the
## untrusted mod warning) as it makes more sense to the user, even though it's
## functionally the same as retry
@export var retry_is_continue: bool = false:
	get:
		return retry_is_continue
	set(value):
		retry_is_continue = value
		_update_retry_is_continue()
## User settings (So it can be changed by stuff like "don't ask me again"
## checkboxes)
@export var user_settings: ModLoaderUserSettings


## Label for displaying error message text
@onready var _error_message_label: Label = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/ErrorMessageLabel")
## Force load button (a.k.a. Load Anyway)
@onready var _force_load_button: Button = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ForceLoadButton")
## Retry mod and continue button (a.k.a. continue, it's functionally the same
## under the hood)
@onready var _retry_button: Button = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RetryButton")
## Skip next mod then continue button
@onready var _skip_button: Button = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/SkipButton")
## Abort (quit application) button
@onready var _abort_button: Button = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AbortButton")
## Cancel mod loading button
@onready var _cancel_button: Button = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CancelButton")
## "Don't ask me again" checkbox when loading untrusted mods
@onready var _skip_untrusted_warning_check_box: CheckBox = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/SkipUntrustedWarningCheckbox")
## Spacer to be displayed between error label and check box if there is a check
## box for this error.
@onready var _check_box_spacer: Control = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/CheckBoxSpacer")

## Configure the error window for the given error and show.
func show_error(error: ModLoadResult):
	can_force_load = error.error == ModLoadResult.LoadError.HASH_MISMATCH
	
	can_cancel = error.error == ModLoadResult.LoadError.LOADING_UNOFFICIAL_MODS
	can_skip = error.error != ModLoadResult.LoadError.LOADING_UNOFFICIAL_MODS
	retry_is_continue = error.error == ModLoadResult.LoadError.LOADING_UNOFFICIAL_MODS
	_skip_untrusted_warning_check_box.visible = error.error == ModLoadResult.LoadError.LOADING_UNOFFICIAL_MODS
	
	_check_box_spacer.visible = _skip_untrusted_warning_check_box.visible
	
	show() # For some reason, needs to be before updating error text or window expands to maximum vertical height
	error_message = error.get_message()


# Override
func _ready():
	_update_error_message()


## Update error message label
func _update_error_message() -> void:
	if (_error_message_label == null):
		push_error("Mod load window does not have error message label set")
		return
	
	_error_message_label.text = error_message


## Show appropriate buttons for errors where you can force load
func _update_can_force_load() -> void:
	_force_load_button.visible = can_force_load


## Show appropriate buttons for cancellable errors
func _update_can_cancel() -> void:
	_cancel_button.visible = can_cancel
	_abort_button.visible = not can_cancel


## Show appropriate buttons for skippable errors
func _update_can_skip() -> void:
	_skip_button.visible = can_skip


## Sets retry button text according to setting
func _update_retry_is_continue() -> void:
	# TODO: Localisation (?? might be handled anyway by button)
	_retry_button.text = "Continue" if retry_is_continue else "Retry"


# Signal connection
func _on_panel_container_resized() -> void:
	# Wrap contents does not shrink the window when children get smaller
	# so we have to do that ourselves
	# TODO: Somebody has reported this here: https://forum.godotengine.org/t/issue-with-wrap-controls-property-containing-window-node-wont-shrink-with-its-contents/81067
	# but it doesn't seem to have gotten much traction. Maybe worth making a
	# minimum reproducible example and raising as a bug?
	size.y = get_child(0).size.y


# Signal connection
func _on_force_load_button_pressed() -> void:
	hide()
	force_load.emit()


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


# Signal connection
func _on_error_message_label_finished() -> void:
	_on_panel_container_resized()


# Signal connection
func _on_cancel_button_pressed() -> void:
	hide()


# Signal connection
func _on_skip_untrusted_warning_checkbox_toggled(toggled_on: bool) -> void:
	# "Don't ask me again" is misleading if you cancel, because future attempts
	# to hit play won't cancel, they'll bypass the warning entirely.
	_cancel_button.disabled = toggled_on
	
	if not is_instance_valid(user_settings):
		return
	
	user_settings.hide_untrusted_warning = toggled_on
