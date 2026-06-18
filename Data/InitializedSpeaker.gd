class_name InitializedSpeaker extends Node


@export var data: bool = false


func set_data(_data: bool = false) -> void:
	data = _data


func get_data() -> bool:
	return data
