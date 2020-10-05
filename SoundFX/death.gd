extends AudioStreamPlayer

#Release when not needed
func _on_death_finished():
	queue_free()
