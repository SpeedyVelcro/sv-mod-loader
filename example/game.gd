extends Node2D
## Gameplay scene
##
## This scene contains a quick-and-dirty bullet-dodging game, provided to help
## test out the mod loader

## Curve along which to spawn bullets
@export var spawn_curve: Curve2D
## Bullet scene
@export var bullet_scene: PackedScene
## Player node
@export var player: Node2D
## Bullet timer
@export var bullet_timer: Timer
## Pause UI Node
@export var pause_ui: CanvasItem
## Game Over UI Node
@export var game_over_ui: CanvasItem

## Menu scene
const MENU_SCENE: String = "res://example/ui/menu/menu.tscn"


## Pick a random point on the spawn curve
func _pick_spawn() -> Vector2:
	var offset: float = randf_range(0.0, spawn_curve.get_baked_length())
	var point: Vector2 = spawn_curve.sample_baked(offset)
	
	return point


## Restart the current game session
func _restart() -> void:
	# Game is likely paused as this is called from the game over screen
	get_tree().paused = false
	
	get_tree().reload_current_scene()


## Return to the main menu
func _return_to_menu() -> void:
	# Game is likely paused as this is called from the game over or pause
	# screens
	get_tree().paused = false
	
	get_tree().change_scene_to_file(MENU_SCENE)


## End the current game in failure
func _game_over() -> void:
	get_tree().paused = true
	pause_ui.pause_disabled = true
	
	game_over_ui.visible = true


# Signal connection
func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	
	bullet.position = _pick_spawn()
	bullet.direction = player.position - bullet.position
	
	add_child(bullet)
	bullet.owner = self
	
	bullet_timer.wait_time *= 0.99


# Signal connection
func _on_pause_return_to_menu() -> void:
	_return_to_menu()


# Signal connection
func _on_game_over_retry() -> void:
	_restart()

# Signal connection
func _on_game_over_return_to_menu() -> void:
	_return_to_menu()


func _on_player_death() -> void:
	_game_over()
