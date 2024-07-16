class_name ScalarAnimation extends Node


@export_category("Scalar Animation")

@export_group("Parameters")
@export var step_values: Array[float]
@export var step_durations: Array[float]
@export var start_step_index: int = 0
@export var is_repeating: bool = true
@export var is_physics_animation: bool = false

var _start_output = null
var _last_full_step_output: float

var _current_step_index: int
var _current_step_delta: float = 0
## Stores a value between 0 and 1 indicating what percentage of the current animation
## step has elapsed.
var _current_step_progress: float = 0


## Must be overridden with a method which updates the node's properties to progress
## the animation, and which returns a value indicating the current state of the animation.
## For an animation which relies on manipulating a single property of the node,
## the returned value can just be the current value of that property.
## If `_start_output` is set to null, the animation should be set to its initial state.
func _update_animation() -> float:
	Methods.throw_error("not implemented")
	return 0


func _ready():
	if len(step_values) != len(step_durations):
		Methods.throw_error(
			"step values array and step durations array must be the same length"
		)

	_on_visibility_changed()

	# Technically this signal is not present on Node, but it is present on both
	# Node2D (through CanvasItem) and Node3D
	self.visibility_changed.connect(_on_visibility_changed)


func _process(delta):
	if (!is_physics_animation) and self.visible:
		__process_animation(delta)


func _physics_process(delta):
	if is_physics_animation and self.visible:
		__process_animation(delta)


func _on_visibility_changed():
	_start_output = null
	_current_step_index = start_step_index
	_current_step_delta = 0

	if self.visible:
		_start_output = _update_animation()
		_last_full_step_output = _start_output

	else:
		_update_animation()


func __process_animation(delta):
	_current_step_delta += delta

	while true:
		var current_step_duration: float = step_durations[_current_step_index]

		if _current_step_delta >= current_step_duration:
			_current_step_progress = 1
			_last_full_step_output = _update_animation()

			_current_step_delta -= current_step_duration
			# Increment step index
			_current_step_index = (_current_step_index+1) % len(step_values)
			

			if (!is_repeating) and (_current_step_index == start_step_index):
				# Stop animation after 1 loop has completed
				self.visible = false
				return

			if current_step_duration == 0:
				# If the current step has no duration, it will be shown for exactly 1 frame/tick
				break

		else:
			_current_step_progress = _current_step_delta/current_step_duration
			_update_animation()
			break
