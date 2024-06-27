extends Window
## Window with interface for creating a new mod list
##
## This scene is a window prompt for creating a new mod list. On completion,
## emits a signal with configuration.

signal confirm(new_name: String, is_copy: bool)

@export_group("Internal Nodes")
## Child confirm button
@export var confirm_button: Button
## Child name line edit
@export var name_line_edit: LineEdit
## Child copy check box
@export var copy_check_box: CheckBox

## Current configured name of the mod list
var mod_list_name: String = "":
	get = get_mod_list_name, set = set_mod_list_name

## True if the new mod list will be a copy of the current one
var mod_list_is_copy: bool = false


## Reset all fields to default
func reset() -> void:
	mod_list_name = ""
	mod_list_is_copy = false
	name_line_edit.text = mod_list_name
	copy_check_box.button_pressed = mod_list_is_copy
	confirm_button.disabled = true


## Get the name of the mod list
func get_mod_list_name() -> String:
	return mod_list_name


## Set the name of the mod list
func set_mod_list_name(val: String) -> void:
	mod_list_name = val
	confirm_button.disabled = not mod_list_name.is_valid_filename()


# Signal connection
func _on_name_line_edit_text_changed(new_text) -> void:
	mod_list_name = new_text


func _on_copy_check_box_toggled(toggled_on) -> void:
	mod_list_is_copy = toggled_on


func _on_confirm_button_pressed():
	confirm.emit(mod_list_name, mod_list_is_copy)
	hide()


func _on_close_requested():
	pass # DO NOT close, as this includes clicking on background window


func _on_cancel_button_pressed():
	hide()


func _on_about_to_popup():
	reset()
