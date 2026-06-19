class_name SingerInfo extends Node


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


func set_data(_data: Dictionary = {}) -> void:
	data = _data


func get_data() -> Dictionary:
	return data
