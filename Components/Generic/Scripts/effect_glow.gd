extends SimpleEffect


func _update():
	if status == STATUS.READY:
		_parent.modulate.a = previous_step_value

	elif status == STATUS.PLAYING:
		var step_difference: float = current_step_value - previous_step_value

		_parent.modulate.a = (
			previous_step_value +
			(step_difference * _current_step_progress)
		)

	return _parent.modulate.a
