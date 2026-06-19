class_name SpeakerInfo extends Node


@export var data: Dictionary = {
	"policy": "",
	"portrait": "",
	"style_infos": [
		{
			"id": 0,
			"icon": "",
			"portrait": "",
			"voice_samples": [ "" ]
		}
	]
}


func set_data(speakers: Dictionary = {}) -> void:
	data = speakers


func get_data() -> Dictionary:
	return data
