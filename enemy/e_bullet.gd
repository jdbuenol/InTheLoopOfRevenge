extends Area2D

var velocity : Vector2 = Vector2(0, 0)
const SPEED : int = 5

#Set the movement tendency
func set_movement(x : float, y : float):
	velocity = Vector2(x, y).normalized() * SPEED

#This executes every frame
func _physics_process(_delta):
	translate(velocity)

#when collides with walls or the player
func _on_e_bullet_body_entered(body):
	if "wall" in body.name:
		queue_free()
	elif "player" == body.name:
		body.death()
