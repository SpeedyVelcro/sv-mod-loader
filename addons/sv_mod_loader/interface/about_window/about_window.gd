extends Window

## Pass-through to RichTextLabel. Passed through on ready.
@export var bbcode_enabled: bool = false:
	get:
		return bbcode_enabled
	set(value):
		bbcode_enabled = value
		_pass_through_values()
## Pass-through to RichTextLabel. Passed through on ready.
@export_multiline var text: String = "":
	get:
		return text
	set(value):
		text = value
		_pass_through_values()
## Pass-through to RichTextLabel. Passed through on ready.
@export var fit_content: bool = false:
	get:
		return fit_content
	set(value):
		fit_content = value
		_pass_through_values()
## Pass-through to RichTextLabel. Passed through on ready.
@export var scroll_active: bool = false:
	get:
		return scroll_active
	set(value):
		scroll_active = value
		_pass_through_values()

@onready var _rich_text_label: RichTextLabel = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/RichTextLabel")


func _ready() -> void:
	_pass_through_values()


func _pass_through_values() -> void:
	if (_rich_text_label == null):
		return
	
	_rich_text_label.bbcode_enabled = bbcode_enabled
	_rich_text_label.text = text
	_rich_text_label.fit_content = fit_content
	_rich_text_label.scroll_active = scroll_active
