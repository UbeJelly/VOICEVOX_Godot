class_name Version extends Node


@export var data: String = ""


func set_data(_data: String = "") -> void:
	data = _data


func get_data() -> String:
	return data
