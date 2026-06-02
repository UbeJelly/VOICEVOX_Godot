class_name AccentPhrases extends Node


@export var data: Array = [
	{
		"moras": [
			{
				"text": "",
				"consonant": "",
				"consonant_length": 0.0,
				"vowel": "",
				"vowel_length": 0.0,
				"pitch": 0.0
			}
		],
		"accent": 1,
		"pause_mora": null,
		"is_interrogative": false
	}
]


func set_data(_data: Array) -> void:
	data = _data


func get_data() -> Array:
	return data
