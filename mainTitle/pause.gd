extends CanvasLayer

#This executes at the start of the scene
func _ready():
	$AnimationPlayer.play("intro")

#Loops through animations
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		$RichTextLabel.visible = true
		$Label.visible = true
		$Label2.visible = true
		$Label3.visible = true
	if anim_name == "outro":
		queue_free()

#This executes every frame
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = false
		get_tree().change_scene("res://mainTitle/mainScreen.tscn")
	elif Input.is_action_just_pressed("pause") || Input.is_mouse_button_pressed(1):
		get_tree().paused = false
		$AnimationPlayer.play("outro")
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
