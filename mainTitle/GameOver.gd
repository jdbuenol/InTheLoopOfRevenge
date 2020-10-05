extends CanvasLayer

var over : bool = false
#This executes at the start of the scene
func _ready():
	$AnimationPlayer.play("intro")

#Loop through the animations
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		$RichTextLabel.visible = true
		$AnimationPlayer.play("intro2")
	if anim_name == "intro2":
		$RichTextLabel.visible = false
		$RichTextLabel2.visible = true
		$AnimationPlayer.play("intro3")
	if anim_name == "intro3":
		$RichTextLabel2.visible = false
		$RichTextLabel3.visible = true
		$RichTextLabel4.visible = true
		$Label.visible = true
		$Label2.visible = true
		$Label3.visible = true
		$Label4.visible = true
		$Label.text = "Score: " + str(get_parent().score)
		$Label2.text = "Revenges completed: " + str(get_parent().revenges)
		$AnimatedSprite.visible = true
		over = true

#This executes every frame
func _physics_process(_delta):
	if Input.is_mouse_button_pressed(1) and over:
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
