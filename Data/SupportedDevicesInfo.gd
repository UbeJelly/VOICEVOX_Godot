class_name SupportedDevicesInfo extends Node


@export var data: Dictionary = {
	"cpu": true,
	"cuda": true,
	"dml": true
}


func set_data(_data: Dictionary = {}) -> void:
	data = _data


func get_data() -> Dictionary:
	return data
