extends KinematicBody2D

var velocity : Vector2 = Vector2()

const SPEED : int = 500

func _physics_process(_delta):

	if Input.is_action_pressed("ui_up"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("ui_down"):
		velocity.y = SPEED
	else:
		velocity.y = 0

	if Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
	else:
		velocity.x = 0

	velocity = velocity.normalized() * SPEED
	velocity = move_and_slide(velocity)
