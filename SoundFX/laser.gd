extends AudioStreamPlayer

#release memory when not necessary
func _on_laser_finished():
	queue_free()
