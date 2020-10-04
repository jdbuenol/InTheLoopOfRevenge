extends Node2D

onready var animation_player : AnimationPlayer = $AnimationPlayer
signal done

func _ready():
	var _dismiss = animation_player.connect("animation_finished", self, "_on_animation_finished")
	animation_player.play("show_godot")

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		if event.pressed and animation_player.is_playing():
			animation_player.seek(max(4.0, animation_player.current_animation_position), true)
	get_tree().set_input_as_handled()

func _on_animation_finished(anim: String):
	if anim == "show_godot":
		emit_signal("done")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://mainTitle/mainScreen.tscn")
