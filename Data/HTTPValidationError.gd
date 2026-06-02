class_name HTTPValidationError extends Node


@export var data: Dictionary = {
	"detail": [
		{
			"loc": [
				"",
				0
			],
			"msg": "",
			"type": ""
		}
	]
}


func set_data(detail: Array = []) -> void:
	data = { "detail": detail }


func get_data() -> Dictionary:
	return data
