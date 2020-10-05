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
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = false
		high_score()
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://mainTitle/mainScreen.tscn")
	elif Input.is_action_just_pressed("pause") || Input.is_mouse_button_pressed(1):
		get_tree().paused = false
		$RichTextLabel.visible = false
		$Label.visible = false
		$Label2.visible = false
		$Label3.visible = false
		$AnimationPlayer.play("outro")
	if Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		high_score()
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()

#Checks and updates the high schore
func high_score():
	var hi_score : File = File.new()
	if ! hi_score.file_exists("user://score.save") and hi_score.open("user://score.save", File.WRITE) == 0:
		hi_score.store_line(str(get_parent().score))
	elif hi_score.open("user://score.save", File.READ) == 0:
		var current_hi : int = int(hi_score.get_line())
		hi_score.close()
		if get_parent().score > current_hi and hi_score.open("user://score.save", File.WRITE) == 0:
			hi_score.store_line(str(get_parent().score))
	hi_score.close()
