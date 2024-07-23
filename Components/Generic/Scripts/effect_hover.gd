extends SimpleEffect


func _update():
	if status == STATUS.PLAYING:
		_parent.position.y = (
			_last_step_output +
			(current_step_value * _current_step_progress)
		)

	return _parent.position.y
