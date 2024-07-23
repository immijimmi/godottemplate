class_name SimpleDeploy extends Node


@export_category("SimpleDeploy")
@export var is_physics_animation: bool = false

## Stores a value between 0 and 1 indicating what percentage of the current animation
## (whether deploying or returning) has elapsed.
var _progress: float


## Must be overridden with a method which updates the node's properties to progress
## the deploy animation, and which returns a value indicating the current state of
## that animation. This value should be a float between 0 and 1.
func _update(delta: float) -> float:
	Methods.throw_error("not implemented")
	return 0


func toggle():
	self.visible = !self.visible


func _on_visibility_changed():
	_progress = 1-_progress


func _ready():
	if self.visible:
		_progress = 0
	else:
		_progress = 1


func _process(delta):
	if !is_physics_animation and (_progress < 1):
		__process_effect(delta)


func _physics_process(delta):
	if is_physics_animation and (_progress < 1):
		__process_effect(delta)


func __process_effect(delta: float):
	_progress = _update(delta)
