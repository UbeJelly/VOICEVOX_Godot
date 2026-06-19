class_name Singers extends Node


@export var data: Array = [
	{
		"name": "",
		"speaker_uuid": "",
		"styles": [
			{
				"name": "",
				"id": 0,
				"type": ""
			}
		],
		"version": "",
		"supported_features": {
			"permitted_synthesis_morphing": ""
		}
	}
]


func set_data(_data: Array = []) -> void:
	data = _data


func get_data() -> Array:
	return data
