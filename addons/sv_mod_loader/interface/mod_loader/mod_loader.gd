extends Control
## Main SV Mod Loader interface
##
## This scene contains a full interface that allows setup of a mod load order
## and starting the game with that load order.

## Emitted when the player attempts to open the "About" menu
signal about_open

## Types of title that can be displayed in the title area
enum TitleType {
	## The default title will be displayed
	DEFAULT,
	## The given text is displayed in place of the default title
	TEXT,
	## The given texture is displayed in place of the default title
	TEXTURE,
	## The given scene is instantiated and inserted into the tree where the
	## default title would be
	SCENE
	}

## Path of directory where mod lists are stored. Used to overwrite the same
## property configured on mod_list_editor.
@export var mod_list_path: String = "user://mod_lists"
## Path of directory where mods are stored. Used to overwrite the same property
## configured on mod_list_editor.
@export var mod_path: String = "user://mods"
## Scene to change to when the "Play" button is pressed. Should be set to the
## path (starting with "res://") of any *.tscn file.
@export_file("*.tscn") var play_scene: String = ""

@export_group("Title")
## The type of title that will be displayed in the title area.
## Determines which of title_text, title_texture, or title_scene take effect
## (if any).
@export var title_type: TitleType = TitleType.DEFAULT
## If title_type is set to TitleType.TEXT, then this text will be displayed
## instead of the default title.
@export var title_text: String = ""
## If title_type is set to TitleType.TEXTURE, then this texture will be
## displayed where the default title would usually go.
@export var title_texture: Texture2D
## If title_type is set to TitleType.SCENE, then this scene will be
## instantiated and added to the tree where the default title would usually
## go.
@export var title_scene: PackedScene

@export_group("About")
## Whether the about button should be displayed
@export var show_about_button: bool = true
## Whether the about window text should recognise BBCode. Same behaviour as
## RichtTextLabel.bbcode_enabled.
##
## Pass-through to AboutWindow. Passed through on ready and on set.
@export var about_bbcode_enabled: bool = false:
	get:
		return about_bbcode_enabled
	set(value):
		about_bbcode_enabled = value
		_pass_through_values()
## Text to display in the about window. Same behaviour as RichTextLabel.text.
##
## Pass-through to AboutWindow. Passed through on ready and on set.
@export_multiline var about_text: String = "":
	get:
		return about_text
	set(value):
		about_text = value
		_pass_through_values()
## Expand the about window to fit content. Same behaviour as
## RichTextLabel.fit_content.
##
## Pass-through to AboutWindow. Passed through on ready and on set.
@export var about_fit_content: bool = false:
	get:
		return about_fit_content
	set(value):
		about_fit_content = value
		_pass_through_values()
## Makes the scrollbar visible in the about window. Same behaviour as
## RichTextLabel.scroll_active.
##
## Pass-through to AboutWindow. Passed through on ready and on set.
@export var about_scroll_active: bool = false:
	get:
		return about_scroll_active
	set(value):
		about_scroll_active = value
		_pass_through_values()

## Child mod list editor scene
@onready var _mod_list_editor: Node = get_node(
	"Panel/MarginContainer/HBoxContainer/ModListEditor")
@onready var _about_button: Button = get_node(
	"Panel/MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/AboutButton")
## Control that displays the default or user-set title text
@onready var _title_label: Label = get_node(
	"Panel/MarginContainer/HBoxContainer/VBoxContainer/TitleLabel")
## Control that displays the user-set title text
@onready var _title_texture_rect: TextureRect = get_node(
	"Panel/MarginContainer/HBoxContainer/VBoxContainer/TitleTextureRect")
## Control to which the user-set title scene will be parented
@onready var _title_scene_parent: Control = get_node(
	"Panel/MarginContainer/HBoxContainer/VBoxContainer/TitleSceneParent")
## About window scene
@onready var _about_window: Window = get_node("AboutWindow")


# Override
func _init() -> void:
	# This is done in the "init" step to get ahead of the "ready" step, which is
	# when all other scenes use these values
	ModListSaver.path = mod_list_path
	ModScanner.path = mod_path

# Override
func _ready() -> void:
	_init_title()
	_pass_through_values()
	
	_about_button.visible = show_about_button

## Switches to the set "play scene". Set save_first to true to save all configs
## before leaving the mod loader.
func play(save_first = true) -> void:
	if save_first:
		save()
	
	if play_scene == "":
		push_warning("Play scene not set on ModLoader")
		return
	
	var success = load_mods()
	if not success:
		push_error("Failed to load mods. Aborting play.")
		# TODO: Popup a message box to the user (not just logging to console)
		# Might have to re-organize some things so we can display the mod name
		# here
		return
	
	get_tree().change_scene_to_file(play_scene)


## Loads mods in the order configured in the mod_list_editor. Returns true if
## successful. Pushes an error (unless you specify not to) and returns false
## if unsuccessful
func load_mods(push_error = true) -> bool:
	save()
	
	var mod_list: ModList = _mod_list_editor.get_mod_list()
	
	for mod: Mod in mod_list.load_order:
		if not mod.enabled:
			continue
		
		var path = ModScanner.filename_to_absolute_path(mod.filename)
		
		var success = ProjectSettings.load_resource_pack(path)
		
		if not success:
			push_error("Failed to load mod as resource pack: " + mod.filename)
			return false
	
	return true


## Saves any currently unsaved configs
func save() -> void:
	_mod_list_editor.save_current()


## Initializes the title according to the exported properties. This assumes
## the scene is in its fresh state, hence calling it multiple times will have
## undefined behaviour.
func _init_title() -> void:
	match title_type:
		TitleType.TEXT:
			_init_title_text()
		TitleType.TEXTURE:
			_init_title_texture()
		TitleType.SCENE:
			_init_title_scene()


## Initializes the title to display title_text
func _init_title_text() -> void:
	_title_label.text = title_text


## Initializes the title to display title_texture
func _init_title_texture() -> void:
	_title_texture_rect.texture = title_texture
	
	_title_label.visible = false
	_title_texture_rect.visible = true


## initializes the title to display title_scene
func _init_title_scene() -> void:
	if (title_scene == null):
		push_error("Tried to initialize title scene, but no title scene was set!")
		return
	
	var scn = title_scene.instantiate()
	_title_scene_parent.add_child(scn)
	
	_title_label.visible = false
	_title_scene_parent.visible = true

## Sets all pass-through values on respective children.
func _pass_through_values() -> void:
	if (_about_window == null):
		return
	
	_about_window.bbcode_enabled = about_bbcode_enabled
	_about_window.text = about_text
	_about_window.fit_content = about_fit_content
	_about_window.scroll_active = about_scroll_active


# Signal connection
func _on_quit_button_pressed() -> void:
	save()
	get_tree().quit()


# Signal connection
func _on_play_button_pressed() -> void:
	play()


# Signal connection
func _on_about_button_pressed() -> void:
	about_open.emit()
	_about_window.popup_centered()
