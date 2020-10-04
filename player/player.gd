extends KinematicBody2D

var velocity : Vector2 = Vector2()
var shooting : bool = false
var dead : bool = false

const BULLET : PackedScene = preload("res://player/bullet.tscn")
const LASER : PackedScene = preload("res://SoundFX/laser.tscn")

const SPEED : int = 500

#This converts from radians to Degrees
func rad_to_deg(rads : float) -> int:
	return int(rads*180/PI)

#This executes every frame
func _physics_process(_delta):
	if ! dead:
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
		if Input.is_mouse_button_pressed(1) and ! shooting:
			get_parent().add_child(LASER.instance())
			shooting = true
			$shootTimer.start()
			var bullet : Area2D = BULLET.instance()
			get_parent().add_child(bullet)
			bullet.global_position = $Position2D.global_position
			bullet.set_movement(mouse_pos.x - global_position.x, mouse_pos.y - global_position.y)
		$Camera2D.offset = Vector2(mouse_pos.x - global_position.x, mouse_pos.y - global_position.y) * 0.1

#Shoot timer
func _on_shootTimer_timeout():
	shooting = false

#Die
func death():
	$CollisionShape2D.queue_free()
	$shootTimer.queue_free()
	dead = true
	z_index = 0
	$AnimatedSprite.play("death")
