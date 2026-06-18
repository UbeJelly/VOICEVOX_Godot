class_name Preset extends Node


@export var data: Dictionary = {
	"id": 0,
	"name": "",
	"speaker_uuid": "",
	"style_id": 0,
	"speedScale": 0,
	"pitchScale": 0,
	"intonationScale": 0,
	"volumeScale": 0,
	"prePhonemeLength": 0,
	"postPhonemeLength": 0,
	"pauseLength": 0,
	"pauseLengthScale": 1
}


func set_data(_data: Dictionary = {}) -> void:
	data = _data


func get_data() -> Dictionary:
	return data
