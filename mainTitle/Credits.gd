extends Control

const SELECT : PackedScene = preload("res://SoundFX/select.tscn")

#This executes every frame
func _physics_process(_delta):
	if Input.is_action_just_pressed("credits"):
		get_parent().current_screen = true
		get_parent().add_child(SELECT.instance())
		queue_free()
