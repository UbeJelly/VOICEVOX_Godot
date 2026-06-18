class_name Presets extends Node


@export var data: Array = []


func set_data(_data: Array = []) -> void:
	data = _data


func get_data() -> Array:
	return data
