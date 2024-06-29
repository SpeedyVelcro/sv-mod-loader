extends Node2D

## Curve along which to spawn bullets
@export var spawn_curve: Curve2D
## Bullet scene
@export var bullet_scene: PackedScene
## Player node
@export var player: Node2D
## Bullet timer
@export var bullet_timer: Timer

## Pick a random point on the spawn curve
func _pick_spawn() -> Vector2:
	var offset: float = randf_range(0.0, spawn_curve.get_baked_length())
	var point: Vector2 = spawn_curve.sample_baked(offset)
	
	return point


# Signal connection
func _on_bullet_timer_timeout() -> void:
	var bullet = bullet_scene.instantiate()
	
	bullet.position = _pick_spawn()
	bullet.direction = player.position - bullet.position
	
	add_child(bullet)
	bullet.owner = self
	
	bullet_timer.wait_time *= 0.99
