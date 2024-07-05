class_name MouseInteractable extends Area2D


signal ordering_outdated

var is_mouse_entered: bool:
	get: return _is_mouse_entered
var topmost_interactable:
	get:
		if len(ordered_interactables) > 0:
			return ordered_interactables[0]
var hovered_interactables: Dictionary:
	get: return __hovered_interactables
	set(value):
		__hovered_interactables.clear()
		for key in value:
			__hovered_interactables[key] = value[key]
var ordered_interactables: Array:
	get:
		if is_ordering_outdated:
			__calculate_interactables_order()
			is_ordering_outdated = false
		return __ordered_interactables
var is_ordering_outdated: bool:
	get: return __is_ordering_outdated_container[0]
	set(value):
		var old_value: bool = __is_ordering_outdated_container[0]

		__is_ordering_outdated_container[0] = value

		if (value != old_value) and (value == true):
			ordering_outdated.emit()
var current_event: InputEvent:
	get: return __current_event_container[0]
	set(value): __current_event_container[0] = value

## Should only contain visible interactables.
var __hovered_interactables: Dictionary = Methods.static_member(
	MouseInteractable, "__hovered_interactables", {}
)
var __ordered_interactables: Array = Methods.static_member(
	MouseInteractable, "__ordered_interactables", []
)
var __is_ordering_outdated_container: Array[bool] = Methods.static_member(
	MouseInteractable, "__is_ordering_outdated_container", [false]
)
## Assumes only one event propagates through the scene tree at a time
var __current_event_container: Array = Methods.static_member(
	MouseInteractable, "__current_event_container", [null]
)

var _is_mouse_entered: bool = false


## Can be overridden. Return value is used to specify which events will be
## passed into `.handle()`.
func can_handle(viewport: Node, event: InputEvent, shape_idx: int) -> bool:
	return (
		(event is InputEventMouseButton) and
		(not event.canceled)
	)


## Can be overridden to handle desired events. Return `true` in order to consume the
## provided event. Default behaviour (along with `.can_handle()`) blocks mouse button events
## (including scrolling) from being passed to interactables rendered underneath this one.
func handle(viewport: Node, event: InputEvent, shape_idx: int) -> bool:
	return true


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	visibility_changed.connect(_on_visibility_changed)
	tree_exiting.connect(_on_tree_exiting)


func _on_mouse_entered():
	_is_mouse_entered = true

	if is_visible_in_tree():
		__hovered_interactables[self] = true
		is_ordering_outdated = true


func _on_mouse_exited():
	_is_mouse_entered = false

	if self in __hovered_interactables:
		__hovered_interactables.erase(self)
		is_ordering_outdated = true


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if current_event == event:
		return
	current_event = event

	for interactable in ordered_interactables:
		if interactable.can_handle(viewport, event, shape_idx):
			var is_consumed: bool = interactable.handle(viewport, event, shape_idx)

			if is_consumed:
				break


func _on_visibility_changed():
	if is_visible_in_tree():
		if _is_mouse_entered and (self not in __hovered_interactables):
			__hovered_interactables[self] = true
			is_ordering_outdated = true
	else:
		if self in __hovered_interactables:
			__hovered_interactables.erase(self)
			is_ordering_outdated = true


func _on_tree_exiting():
	if self in __hovered_interactables:
		__hovered_interactables.erase(self)
		is_ordering_outdated = true


func __calculate_interactables_order():
	__ordered_interactables = __hovered_interactables.keys()
	__ordered_interactables.sort_custom(
		Methods.reverse_render_order_sort_key
	)
