class_name Speakers extends Node


@export var data: Array = [
	{
		"name": "",
		"speaker_uuid": "",
		"styles": [
			{
				"id": 0.0,
				"name": "",
				"type": ""
			}
		],
		"supported_features": {
			"permitted_synthesis_morphing": ""
		},
		"version": ""
	}
]


func set_data(speakers: Array = []) -> void:
	data = speakers


func get_data() -> Array:
	return data
