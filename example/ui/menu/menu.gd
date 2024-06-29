extends Control

## Game scene
const GAME_SCENE: String = "res://example/game.tscn"


# Signal connection
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


# Signal connection
func _on_quit_button_pressed() -> void:
	get_tree().quit()
