extends SimpleEffect


@export var is_repeating: bool = true:
	get: return _is_repeating
	set(value): _is_repeating = value
@export var is_persistent: bool = true:
	get: return _is_persistent
	set(value): _is_persistent = value
@export var is_physics_animation: bool = false:
	get: return _is_physics_animation
	set(value): _is_physics_animation = value


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
