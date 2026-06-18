class_name ParseKanaBadRequest extends Node


@export var data: Dictionary = {
	"text": "",
	"error_name": "",
	"error_args": {
		"additionalProp1": "",
		"additionalProp2": "",
		"additionalProp3": "",
	}
}


func set_data(_data: Dictionary = {}) -> void:
	data = _data


func get_data() -> Dictionary:
	return data
