class_name AudioQuery extends Node


@export var data: Dictionary = {
	"accent_phrases": [
		{
			"accent": 0.0,
			"is_interrogative": false,
			"moras": [
				{
					"consonant": "",
					"consonant_length": 0.0,
					"pitch": 0.0,
					"text": "",
					"vowel": "",
					"vowel_length": 0.0
				}
			],
			"pause_mora": null
		}
	],
	"intonationScale": 0.0,
	"kana": "",
	"outputSamplingRate": 0.0,
	"outputStereo": false,
	"pauseLength": null,
	"pauseLengthScale": 0.0,
	"pitchScale": 0.0,
	"postPhonemeLength": 0.0,
	"prePhonemeLength": 0.0,
	"speedScale": 0.0,
	"volumeScale": 0.0
}


func set_data(accent_phrases: Array = [], intonation_scale: float = 0.0, kana: String = "", output_sampling_rate: float = 0.0, output_stereo: bool = false, pause_length: Variant = null, pause_length_scale: float = 0.0, pitch_scale: float = 0.0, post_phoneme_length: float = 0.0, pre_phoneme_length: float = 0.0, speed_scale: float = 0.0, volume_scale: float = 0.0) -> void:
	data = {
		"accent_phrases": accent_phrases,
		"intonationScale": intonation_scale,
		"kana": kana,
		"outputSamplingRate": output_sampling_rate,
		"outputStereo": output_stereo,
		"pauseLength": pause_length,
		"pauseLengthScale": pause_length_scale,
		"pitchScale": pitch_scale,
		"postPhonemeLength": post_phoneme_length,
		"prePhonemeLength": pre_phoneme_length,
		"speedScale": speed_scale,
		"volumeScale": volume_scale
	}


func get_data() -> Dictionary:
	return data
