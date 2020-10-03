extends KinematicBody2D

var velocity : Vector2 = Vector2()

const SPEED : int = 500

#This converts from radians to Degrees
func rad_to_deg(rads : float) -> int:
	return int(rads*180/PI)

#This executes every frame
func _physics_process(_delta):

	var mouse_pos : Vector2 = get_global_mouse_position()

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
	rotation_degrees = 180-rad_to_deg(atan2(mouse_pos.x - global_position.x, mouse_pos.y - global_position.y))
