class_name UserDict extends Node


@export var data: Dictionary = {
	"additionalProp1": {
		"surface": "",
		"priority": 10,
		"context_id": 1348,
		"part_of_speech": "",
		"part_of_speech_detail_1": "",
		"part_of_speech_detail_2": "",
		"part_of_speech_detail_3": "",
		"inflectional_type": "",
		"inflectional_form": "",
		"stem": "",
		"yomi": "",
		"pronunciation": "",
		"accent_type": 0,
		"mora_count": 0,
		"accent_associative_rule": ""
	},
}


func set_data(speakers: Dictionary = {}) -> void:
	data = speakers


func get_data() -> Dictionary:
	return data
