class_name FrameAudioQuery extends Node


@export var data: Dictionary = {
	"f0": [0],
	"volume": [0],
	"phonemes": [
		{
			"phoneme": "",
			"frame_length": 0,
			"note_id": ""
		}
	],
	"volumeScale": 0,
	"outputSamplingRate": 0,
	"outputStereo": true
}


func set_data(f0: Array = [], volume: Array = [], phonemes: Array = [], volume_scale: int = 0, output_sampling_rate: int = 0, output_stereo: bool = true) -> void:
	data = {
		"f0": f0,
		"volume": volume,
		"phonemes": phonemes,
		"volumeScale": volume_scale,
		"outputSamplingRate": output_sampling_rate,
		"outputStereo": output_stereo
	}


func get_data() -> Dictionary:
	return data
