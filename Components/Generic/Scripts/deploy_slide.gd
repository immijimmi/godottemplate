extends SimpleDeploy


@export_group("Parameters")
@export var deploy_direction: Side
## The total number of pixels moved when deployed.
@export var deploy_offset: int
## The number of pixels moved per second when deployed (before any attenuation is applied).
@export var deploy_initial_speed: float
## The minimum number of pixels moved per second when deployed (regardless of attenuation).
## Should be greater than 0.
@export var deploy_minimum_speed: float
## This value is applied as an exponent to the current progress, to calculate the current
## speed. Bigger value = stronger slow-down.
@export var deploy_attenuation: float = 2

@export_group("Debug")
@export var do_print_deceleration: bool

var _deployed_coord: float
var _not_deployed_coord: float


func _update() -> float:
	if status == STATUS.READY:
		if (deploy_direction == SIDE_BOTTOM) or (deploy_direction == SIDE_TOP):
			return _parent.position.y
		else:
			return _parent.position.x

	else:
		var current_speed_mult: float = (
			(1-_current_toggle_progress) ** deploy_attenuation
		)
		var current_speed: float = max(
			deploy_minimum_speed,
			deploy_initial_speed * current_speed_mult
		)

		#####


func _ready():
	_is_physics_animation = true

	super()

	if _initial_deploy_state:
		_deployed_coord = _initial_output

		if deploy_direction in {SIDE_LEFT: true, SIDE_TOP: true}:
			_not_deployed_coord = _deployed_coord + deploy_offset
		else:
			_not_deployed_coord = _deployed_coord - deploy_offset
	else:
		_not_deployed_coord = _initial_output

		if deploy_direction in {SIDE_RIGHT: true, SIDE_BOTTOM: true}:
			_deployed_coord = _not_deployed_coord + deploy_offset
		else:
			_deployed_coord = _not_deployed_coord - deploy_offset
