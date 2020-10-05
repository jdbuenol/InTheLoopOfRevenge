extends Control

var over : bool = false

#This executes at the start of the scene
func _ready():
	$AnimationPlayer.play("intro")

#Revenge
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro":
		$CanvasLayer/Label.visible = true
		$CanvasLayer/Label2.visible = true
		over = true
	elif anim_name == "outro":
		queue_free()

#This executes every frame
func _physics_process(_delta):
	if Input.is_mouse_button_pressed(1) and over:
		$CanvasLayer/Label.visible = false
		$CanvasLayer/Label2.visible = false
		$AnimationPlayer.play("outro")
