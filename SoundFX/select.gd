extends AudioStreamPlayer

#Release when not needed
func _on_select_finished():
	queue_free()
