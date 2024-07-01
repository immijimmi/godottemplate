extends Node


var _random_number_generator = RandomNumberGenerator.new()


# Resource Methods

func require(path):
	if not ResourceLoader.exists(path):
		var error_msg = "Could not load resource from file: %s" % str(path)
		throw_error(error_msg)

	return path


# Data Methods

## Used to sum the stored values of a dictionary.
func sum_dict_values(target_dict: Dictionary):
	var is_first_value_set = false
	var result
	for value in target_dict.values():
		if not is_first_value_set:
			result = value
			is_first_value_set = true
		else:
			result += value

	return result


## Used to invert a dictionary whose stored values are arrays.
func invert_array_lookup(target_dict):
	var result = {}
	for key in target_dict:
		var value_array = target_dict[key]
		for value in value_array:
			result[value] = result.get(value, []) + [key]

	return result


# Class Methods

## Abuses node metadata to store a singleton value on a class, and returns that value.
func static_member(target_class, metadata_key: String, value):
	if not target_class.has_meta(metadata_key):
		target_class.set_meta(metadata_key, value)

	return target_class.get_meta(metadata_key)


# Node Methods

## Returns the absolute Z index (converting relative values) of a node in a 2D scene.
func get_absolute_z_index(target_node) -> int:
	var result = 0

	if target_node is CanvasItem:
		result += target_node.z_index

		if target_node.z_as_relative:
			result += get_absolute_z_index(target_node.get_parent())

	return result


## Returns the list of indexes representing the path down the scene tree to the provided node.
func get_scene_tree_indexes(target_node: Node) -> Array:
	var result = []

	if target_node is Node:
		result = get_scene_tree_indexes(target_node.get_parent())
		result.append(target_node.get_index(true))

	return result


## Used to sort a list of nodes in a 2D scene in reverse of the order in which they are
## rendered in the scene (i.e. with the topmost node first).
## Note: Does not currently take Visibility properties (Visible, Top Level,
## Show Behind Parent etc.) nor Y Sort Enabled into account.
func reverse_render_order_sort_key(a, b):
	var a_primary_key = -get_absolute_z_index(a)
	var b_primary_key = -get_absolute_z_index(b)

	if a_primary_key != b_primary_key:
		return a_primary_key < b_primary_key

	var a_indexes = get_scene_tree_indexes(a)
	var b_indexes = get_scene_tree_indexes(b)

	for node_index in range(min(len(a_indexes), len(b_indexes))):
		var a_secondary_key = -a_indexes[node_index]
		var b_secondary_key = -b_indexes[node_index]

		if a_secondary_key != b_secondary_key:
			return a_secondary_key < b_secondary_key

	var a_tertiary_key = -len(a_indexes)
	var b_tertiary_key = -len(b_indexes)

	return a_tertiary_key < b_tertiary_key


# Random Number Generator Methods

## Returns a pseudo-randomly chosen key from the provided dictionary, using the values stored
## under their respective keys as the relative weights. `total_weight` can optionally be
## passed in, which allows it to be calculated ahead of time for optimisation purposes.
func simple_weighted_choice(weights_dict: Dictionary, total_weight=null):
	if total_weight == null:
		total_weight = sum_dict_values(weights_dict)

	var roll = _random_number_generator.randf() * total_weight

	var cumulative_weight = 0
	for key in weights_dict:
		var weight = weights_dict[key]
		cumulative_weight += weight

		if cumulative_weight >= roll:
			return key


# Error Methods

func throw_error(error_msg):
	printerr(error_msg)

	var x = 1
	var y = 0
	x/y
