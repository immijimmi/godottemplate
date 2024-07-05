extends MouseInteractable


signal focus_start
signal focus_end

signal leftclick
signal leftclick_pending
signal leftclick_canceled

signal rightclick

var is_focused: bool:
	get: return _is_focused
	set(value):
		if value != _is_focused:
			_is_focused = value

			if value == true:
				focus_start.emit()
			else:
				focus_end.emit()
var is_leftclick_pending: bool:
	get: return _is_leftclick_pending

var _is_focused: bool = false
var _is_leftclick_pending: bool = false


func handle(viewport: Node, event: InputEvent, shape_idx: int) -> bool:
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _is_leftclick_pending:
				_is_leftclick_pending = true
				leftclick_pending.emit()
		else:
			if _is_leftclick_pending:
				_is_leftclick_pending = false
				leftclick.emit()

	if event.button_index == MOUSE_BUTTON_RIGHT:
		if not event.pressed:
			rightclick.emit()

	return true


func _ready():
	super()

	ordering_outdated.connect(_on_ordering_outdated)


func _on_mouse_exited():
	super()

	if _is_leftclick_pending:
		_is_leftclick_pending = false
		leftclick_canceled.emit()


func _on_ordering_outdated():
	if (self in hovered_interactables) and (topmost_interactable == self):
		is_focused = true
	else:
		is_focused = false
