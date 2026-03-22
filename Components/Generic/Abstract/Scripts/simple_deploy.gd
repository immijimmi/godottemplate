class_name SimpleDeploy extends Node


enum STATUS {READY, PLAYING}


@onready var _parent: Node = get_parent()

var status: STATUS:
	get:
		if _initial_output == null:
			return STATUS.READY
		else:
			return STATUS.PLAYING

var _is_physics_animation: bool = false  # Virtual

var _initial_deploy_state: bool
var _initial_output = null

var _current_toggle_delta: float = 0
## Stores a value between 0 and 1 indicating what percentage of the current animation
## (whether deploying or returning) has elapsed.
var _current_toggle_progress: float = 1


func toggle():
	self.visible = !self.visible


## Must be overridden with a method which updates the node's state to progress
## the deploy animation, and which returns a value indicating the current status of
## that animation.
## Cases which should be considered by this method:
## - If `status` is `STATUS.READY`, the node should have any of its variables which would be
##   manipulated by this animation set to appropriate starting values to begin playing,
##   and this method should return a value which represents this starting state.
##   For an animation which relies on manipulating a single property of the node,
##   the returned value can just be the current value of that property
## - If `status` is `STATUS.PLAYING`, a deploy/return animation is playing and this method
##   should progress it according to the states of the node's variables and should then return
##   a value between 0 and 1 representing how close the current animation is to completion
func _update() -> float:
	Methods.throw_error("not implemented")
	return 0


func _ready():
	_initial_deploy_state = self.visible
	_initial_output = _update()

	# Technically this signal is not present on Node, but it is present on both
	# Node2D (through CanvasItem) and Node3D
	self.visibility_changed.connect(_on_visibility_changed)


func _process(delta):
	if !_is_physics_animation and (_current_toggle_progress < 1):
		__process_effect(delta)


func _physics_process(delta):
	if _is_physics_animation and (_current_toggle_progress < 1):
		__process_effect(delta)


func _on_visibility_changed():
	_current_toggle_progress = 1 - _current_toggle_progress
	_current_toggle_delta = 0


func __process_effect(delta: float):
	_current_toggle_delta += delta
	_current_toggle_progress = _update()
