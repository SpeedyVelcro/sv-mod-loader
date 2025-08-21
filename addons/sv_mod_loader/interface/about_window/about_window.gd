extends Window

## Pass-through to RichTextLabel. Passed through on ready and on set.
@export var bbcode_enabled: bool = false:
	get:
		return bbcode_enabled
	set(value):
		bbcode_enabled = value
		_pass_through_values()
## Pass-through to RichTextLabel. Passed through on ready and on set.
@export_multiline var text: String = "":
	get:
		return text
	set(value):
		text = value
		_pass_through_values()
## Pass-through to RichTextLabel. Passed through on ready and on set.
@export var fit_content: bool = false:
	get:
		return fit_content
	set(value):
		fit_content = value
		_pass_through_values()
## Pass-through to RichTextLabel. Passed through on ready and on set.
@export var scroll_active: bool = false:
	get:
		return scroll_active
	set(value):
		scroll_active = value
		_pass_through_values()

## Child rich text label node
@onready var _rich_text_label: RichTextLabel = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/RichTextLabel")


# Override
func _ready() -> void:
	_pass_through_values()


## Pass all pass-through values to children
func _pass_through_values() -> void:
	if (_rich_text_label == null):
		return
	
	_rich_text_label.bbcode_enabled = bbcode_enabled
	_rich_text_label.text = text
	_rich_text_label.fit_content = fit_content
	_rich_text_label.scroll_active = scroll_active


# Signal connection
func _on_panel_container_resized() -> void:
	# Wrap contents does not shrink the window when children get smaller
	# so we have to do that ourselves
	# TODO: Somebody has reported this here: https://forum.godotengine.org/t/issue-with-wrap-controls-property-containing-window-node-wont-shrink-with-its-contents/81067
	# but it doesn't seem to have gotten much traction. Maybe worth making a
	# minimum reproducible example and raising as a bug?
	size.y = get_child(0).size.y


# Signal connection
func _on_close_button_pressed() -> void:
	hide()
