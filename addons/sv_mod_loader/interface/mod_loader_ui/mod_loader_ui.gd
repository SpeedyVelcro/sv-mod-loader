class_name ModLoaderUI
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

## Path where mod loader user settings file will be stored.
@export var user_settings_path: String = "user://mod_loader/user_settings.json"
## Path of directory where mod lists are stored. Passed through to child mod
## list editor on ready.
@export var mod_list_path: String = "user://mod_lists"
## Path of directory where mods are stored. Passed through to child mod list
## editor on ready.
##
## NB: mod loader is not updated if this value is updated after ready.
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

@export_group("Required Mods")
## Mods that are required to launch the game. They will be automatically
## enabled, and users will not be able to disable them. This is passed through
## to the mod list editor on ready.
@export var required_mods: Array[ModRequirement] = []
## Whether to verify the integrity of the required mods before launching the
## game. This uses MD5 hashes. It is strongly recommended that you keep this
## set to TRUE, as disabling this will put users at risk of attacks from
## malicious actors by replacing your required mods. This is passed through to
## the mod list editor on ready.
@export var verify_required_mods: bool

@export_group("Official Mods")
## Mods that are officially endorsed by the author of the game. Loading these
## mods will not show a safety warning, as the game author has presumably
## already vouched for their safety.
@export var official_mods: Array[OfficialMod] = []

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
## Control that displaysButton the default or user-set title text
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
## Mod load error window scene
@onready var _mod_load_error_window: Window = get_node("ModLoadErrorWindow")
## Settings window scene
@onready var _settings_window: Window = get_node("SettingsWindow")


## Mod loader
var _mod_loader: ModLoader
## User settings access
var _user_settings_access: ModLoaderUserSettingsAccess
## User settings
var _user_settings: ModLoaderUserSettings


# Override
func _ready() -> void:
	_init_title()
	_pass_through_values()
	
	_mod_list_editor.mod_list_path = mod_list_path
	_mod_list_editor.mod_path = mod_path
	_mod_list_editor.required_mods = required_mods
	_mod_list_editor.verify_required_mods = verify_required_mods
	_mod_list_editor.populate()
	
	_about_button.visible = show_about_button
	
	_user_settings_access = ModLoaderUserSettingsAccess.new(user_settings_path)
	_user_settings = _user_settings_access.load_file()
	_settings_window.user_settings = _user_settings
	
	_mod_loader = ModLoader.new(mod_path)
	_mod_loader.finished.connect(_on_mod_loader_finished)

## Switches to the set "play scene". Set save_first to true to save all configs
## before leaving the mod loader.
func play(save_first = true) -> void:
	if save_first:
		save()
	
	if play_scene == "":
		push_warning("Play scene not set on ModLoaderUI")
		return
	
	var mods: Array[Mod] = _mod_list_editor.get_mod_list().to_array()
	
	var results = _mod_loader.load_all(mods, required_mods, verify_required_mods, official_mods)
	
	_handle_mod_load_results(results)


## Saves any currently unsaved configs
func save() -> void:
	_mod_list_editor.save_current()


func _handle_mod_load_results(results: Array[ModLoadResult]):
	if results.is_empty():
		return
	
	var last_error = results.back()
	
	if last_error.status != ModLoadResult.Status.SUCCESS:
		_mod_load_error_window.show_error(last_error)


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
func _on_mod_loader_finished() -> void:
	# User settings can be changed by loading process (due to "ignore from now
	# on" checkboxes) so we need to save any changes
	_user_settings_access.save_file(_user_settings)
	
	get_tree().change_scene_to_file(play_scene)


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


# Signal connection
func _on_settings_button_pressed() -> void:
	_settings_window.popup_centered()


# Signal connection
func _on_mod_load_error_window_retry() -> void:
	var results = _mod_loader.retry_next_and_continue()
	_handle_mod_load_results(results)


# Signal connection
func _on_mod_load_error_window_skip() -> void:
	_mod_loader.skip_next_and_continue()


# Signal connection
func _on_settings_window_finished_editing() -> void:
	_user_settings_access.save_file(_user_settings)


## Called before destroy
func _destructor() -> void:
	_user_settings_access.save_file(_user_settings)
	
	if _mod_loader != null and _mod_loader.finished.is_connected(_on_mod_loader_finished):
		_mod_loader.finished.disconnect(_on_mod_loader_finished)


# Override
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			_destructor()
