extends ScalarAnimation


func _update():
	if status == STATUS.READY:
		var previous_step_index: int = (
			((start_step_index-1) + len(step_values)) % len(step_values)
		)
		var previous_step_value: float = step_values[previous_step_index]

		_parent.modulate.a = previous_step_value
		return _parent.modulate.a

	elif status == STATUS.PLAYING:
		var previous_step_index: int = (
			((start_step_index-1) + len(step_values)) % len(step_values)
		)
		var previous_step_value: float = step_values[previous_step_index]
		var current_step_value: float = step_values[_current_step_index]

		var step_difference: float = current_step_value - previous_step_value

		_parent.modulate.a = (
			previous_step_value +
			(step_difference * _current_step_progress)
		)
		return _parent.modulate.a
