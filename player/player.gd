extends KinematicBody2D

var velocity : Vector2 = Vector2()
var shooting : bool = false
var dead : bool = false

const BULLET : PackedScene = preload("res://player/bullet.tscn")
const LASER : PackedScene = preload("res://SoundFX/laser.tscn")
const DEATH : PackedScene = preload("res://SoundFX/death.tscn")

const SPEED : int = 500

var current_weapon : int = 0
enum weapon {single, helix, double, triple, wizard, triple_spread, quad_spread, pent_spread, weak, frequent, double_frequent, very_weak}

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
			match current_weapon:
				weapon.single:
					normal_weapons_support()
					var bullet : Area2D = BULLET.instance()
					get_parent().add_child(bullet)
					bullet.global_position = $Position2D.global_position
					bullet.set_movement(mouse_pos.x - global_position.x, mouse_pos.y - global_position.y)
				weapon.helix:
					normal_weapons_support()
					for x in range(2):
						var bullet : Area2D = BULLET.instance()
						get_parent().add_child(bullet)
						if x == 0:
							bullet.global_position = $Position2D.global_position
							bullet.set_movement(mouse_pos.x - global_position.x, mouse_pos.y - global_position.y)
						else:
							bullet.global_position = $Position2D2.global_position
							bullet.set_movement(mouse_pos.x - global_position.x + $Position2D.global_position.x - $Position2D2.global_position.x, mouse_pos.y - global_position.y + $Position2D.global_position.y - $Position2D2.global_position.y)
				weapon.double:
					normal_weapons_support()
					for x in range(2):
						var bullet : Area2D = BULLET.instance()
						get_parent().add_child(bullet)
						if x == 0:
							bullet.global_position = $Position2D.global_position
							bullet.set_movement(mouse_pos.x - global_position.x, mouse_pos.y - global_position.y)
						else:
							bullet.global_position = $Position2D2.global_position
							bullet.set_movement(mouse_pos.x - global_position.x - $Position2D.global_position.x + $Position2D2.global_position.x, mouse_pos.y - global_position.y - $Position2D.global_position.y + $Position2D2.global_position.y)
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
	get_parent().add_child(DEATH.instance())
	$AnimatedSprite.play("death")

#Game Over
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "death":
		get_parent().game_over()

#normal weapons
func normal_weapons_support():
	$shootTimer.wait_time = 0.2
	$shootTimer.start()
