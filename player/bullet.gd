extends Area2D

var velocity : Vector2 = Vector2(0, 0)
const SPEED : int = 20

#Set the movement tendency
func set_movement(mov : Vector2):
	velocity = mov.normalized() * SPEED

#This executes every frame
func _physics_process(_delta):
	translate(velocity)

#when collides with walls or enemies
func _on_bullet_body_entered(body):
	if "wall" in body.name:
		queue_free()
	if "enemy" in body.name:
		body.death()
