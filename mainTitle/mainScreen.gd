extends Control

var current_screen : bool = true

#This executes at the start of the scene
func _ready():
	$RichTextLabel.visible = true
	$AnimationPlayer.play("intro")

#Loop animations
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		help_animation(2)
	elif anim_name == "intro5":
		$RichTextLabel5.visible = false
		for x in range(6, 11):
			get_node("RichTextLabel" + str(x)).visible = true
			$Label.visible = true
			$Label2.visible = true
			$Label3.visible = true
	else:
		help_animation(int(anim_name[-1]) + 1)

#Helper of animation player
func help_animation(current_anim : int):
	if current_anim == 2:
		$RichTextLabel.visible = false
	else:
		get_node("RichTextLabel" + str(current_anim - 1)).visible = false
	get_node("RichTextLabel" + str(current_anim)).visible = true
	$AnimationPlayer.play("intro" + str(current_anim))

#This executes every frame
func _physics_process(_delta):
	$cursor.global_position = get_global_mouse_position()
	if current_screen:
		if Input.is_mouse_button_pressed(1):
	# warning-ignore:return_value_discarded
			get_tree().change_scene("res://level/level.tscn")
		if Input.is_action_just_pressed("ui_cancel"):
			get_tree().quit()
		if Input.is_action_just_pressed("credits"):
			current_screen = false

#Replay the song
func _on_AudioStreamPlayer_finished():
	$AudioStreamPlayer.play()
