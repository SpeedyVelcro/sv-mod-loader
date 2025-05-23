## Dummy file, not to be exported.
extends RigidBody2D

@export var speed: int = 400

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	pass

func _on_body_entered(body: Node) -> void:
	pass

func _on_life_timer_timeout() -> void:
	pass
