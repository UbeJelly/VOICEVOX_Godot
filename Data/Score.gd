class_name Score extends Node


@export var data: Dictionary = {
	"notes": [
		{
			"id": "",
			"key": 0,
			"frame_length": 0,
			"lyric": ""
		}
	]
}


func set_data(notes: Array = []) -> void:
	data = { "notes": notes }


func get_data() -> Dictionary:
	return data
