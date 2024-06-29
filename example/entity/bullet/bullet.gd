extends RigidBody2D

## How fast the bullet moves
@export var speed: int = 400
## The initial direction of the bullet. Can be given as a vector of any
## magnitude, as only the direction is used.
var direction: Vector2 = Vector2.RIGHT


# Override
func _ready() -> void:
	linear_velocity = direction.normalized() * speed

# TODO: Destroy after a certain amount of time


# Signal connection
func _on_body_entered(body: Node) -> void:
	# Due to collision mask this must be the player
	visible = false
	body.kill()
	queue_free()


# Signal connection
func _on_life_timer_timeout() -> void:
	queue_free()
