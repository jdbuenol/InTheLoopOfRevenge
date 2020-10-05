extends KinematicBody2D

var velocity : Vector2 = Vector2()
var dir_player : Vector2 = Vector2()
var speed : float = 0
var shooting : bool = false
var reload : bool = false
var dead : bool = false

const E_BULLET : PackedScene = preload("res://enemy/e_bullet.tscn")

#This executes at the start of the scene
func _init():
	randomize()
	speed = rand_range(100, 300)

#This function executes every frame
func _physics_process(_delta):
	if ! dead:
		velocity = move_and_slide(velocity)
		if shooting and ! reload:
			reload = true
			$reloadTimer.start()
			var e_bullet : Area2D = E_BULLET.instance()
			get_parent().add_child(e_bullet)
			e_bullet.global_position = global_position
			e_bullet.set_movement(dir_player.x, dir_player.y)

#Reload timer
func _on_reloadTimer_timeout():
	reload = false

#Die
func death():
	get_parent().up_score()
	z_index = -1
	$CollisionShape2D.queue_free()
	$reloadTimer.queue_free()
	dead = true
	$AnimatedSprite.play("death")
