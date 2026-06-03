class_name CancellableSynthesis extends Node


@export var data: PackedByteArray = []


func set_data(wav_data: PackedByteArray = []) -> void:
	data = wav_data


func get_data() -> PackedByteArray:
	return data
