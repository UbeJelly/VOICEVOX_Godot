class_name MoraPitch extends Node

@export var data: Array = [
	{
		"moras": [
			{
				"text": "",
				"consonant": "",
				"consonant_length": 0,
				"vowel": "",
				"vowel_length": 0,
				"pitch": 0
			}
		],
		"accent": 0,
		"pause_mora": {
			"text": "",
			"consonant": "",
			"consonant_length": 0,
			"vowel": "",
			"vowel_length": 0,
			"pitch": 0
		},
		"is_interrogative": false
	}
]


func set_data(_data: Array = []) -> void:
	data = _data


func get_data() -> Array:
	return data
