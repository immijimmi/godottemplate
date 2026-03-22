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
	if status == STATUS.PLAYING:
		_parent.position.y = (
			_last_step_output +
			(current_step_value * _current_step_progress)
		)

	return _parent.position.y
