class_name SimpleEffect extends Node


enum STATUS {READY, PLAYING, STOPPED}


@export_category("SimpleEffect")
@export var step_values: Array[float]
@export var step_durations: Array[float]
@export var start_step_index: int = 0
@export var is_repeating: bool = true
@export var is_persistent: bool = true
@export var is_physics_animation: bool = false

@onready var _parent = get_parent()

var status: STATUS:
	get:
		if _start_output == null:
			return STATUS.READY
		else:
			if self.visible:
				return STATUS.PLAYING
			else:
				return STATUS.STOPPED

var current_step_index: int:
	get: return __current_step_index
	set(value):
		__current_step_index = value
		__previous_step_index = ((value-1) + len(step_values)) % len(step_values)
		__next_step_index = (value+1) % len(step_values)
var previous_step_index: int:
	get: return __previous_step_index
var next_step_index: int:
	get: return __next_step_index

var current_step_value: float:
	get: return step_values[current_step_index]
var previous_step_value: float:
	get: return step_values[previous_step_index]
var next_step_value: float:
	get: return step_values[next_step_index]

var _start_output = null
var _last_step_output: float
var _last_output: float

var _current_step_delta: float = 0
## Stores a value between 0 and 1 indicating what percentage of the current animation
## step has elapsed.
var _current_step_progress: float = 0

var __previous_step_index: int
var __current_step_index: int
var __next_step_index: int 


## Must be overridden with a method which updates the node's properties to progress
## the effect's animation, and which returns a value indicating the current state of
## that animation. For an animation which relies on manipulating a single property of the node,
## the returned value can just be the current value of that property.
## Cases which should be considered by this method:
## - If `status` is `STATUS.READY`, the animation should have its state set to appropriate
##   values to begin playing (or to continue playing, if the animation is persistent)
## - If `status` is `STATUS.STOPPED`, the animation has just been stopped and should have
##   its state set accordingly (the appropriate state for a stopped animation will depend
##   on your desired behaviour for that animation)
## - If `status` is `STATUS.PLAYING`, the animation is playing and this method should
##   progress it according to the states of the node's variables
func _update() -> float:
	Methods.throw_error("not implemented")
	return 0


func _ready():
	if len(step_values) != len(step_durations):
		Methods.throw_error(
			"step values array and step durations array must be the same length"
		)

	# Initial setup
	current_step_index = start_step_index
	_last_output = _update()
	_last_step_output = _last_output
	_start_output = _last_output

	# Technically this signal is not present on Node, but it is present on both
	# Node2D (through CanvasItem) and Node3D
	self.visibility_changed.connect(_on_visibility_changed)


func _process(delta):
	if (!is_physics_animation) and self.visible:
		__process_effect(delta)


func _physics_process(delta):
	if is_physics_animation and self.visible:
		__process_effect(delta)


func _on_visibility_changed():
	if self.visible:
		if !is_persistent:
			current_step_index = start_step_index
			_start_output = null
			_current_step_delta = 0

		_last_output = _update()
		_last_step_output = _last_output
		_start_output = _last_output

	else:
		_last_output = _update()


func __process_effect(delta: float):
	_current_step_delta += delta

	while true:
		var current_step_duration: float = step_durations[current_step_index]

		if _current_step_delta >= current_step_duration:
			_current_step_progress = 1

			_last_output = _update()
			_last_step_output = _last_output

			# Increment step index
			current_step_index = next_step_index

			_current_step_delta -= current_step_duration

			if (!is_repeating) and (current_step_index == start_step_index):
				# Stop animation after 1 loop has completed
				self.visible = false
				return

			if current_step_duration == 0:
				# If the current step has no duration, it will be shown for exactly 1 frame/tick
				break

		else:
			_current_step_progress = _current_step_delta/current_step_duration
			_update()
			break
