class_name CoreVersions extends Node


@export var data: PackedStringArray = []


func set_data(_data: PackedStringArray = []) -> void:
	data = _data


func get_data() -> PackedStringArray:
	return data
