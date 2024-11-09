extends CharacterBody2D

signal death

## How fast the player moves
@export var speed: int = 400


# Override
func _physics_process(_delta) -> void:
	velocity = Vector2(0, 0)
	
	if Input.is_action_pressed("move_up"):
		velocity += Vector2.UP
	if Input.is_action_pressed("move_down"):
		velocity += Vector2.DOWN
	if Input.is_action_pressed("move_left"):
		velocity += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		velocity += Vector2.RIGHT
	
	velocity = velocity.normalized()
	velocity *= speed
	
	move_and_slide()


## Call this to cause the player to lose the game
func kill() -> void:
	visible = false
	death.emit()
