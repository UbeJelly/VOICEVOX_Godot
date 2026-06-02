class_name AudioQueryFromPreset extends Node


@export var data: Dictionary = {
	"accent_phrases": [
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
	],
	"speedScale": 0,
	"pitchScale": 0,
	"intonationScale": 0,
	"volumeScale": 0,
	"prePhonemeLength": 0,
	"postPhonemeLength": 0,
	"pauseLength": 0,
	"pauseLengthScale": 1,
	"outputSamplingRate": 0,
	"outputStereo": true,
	"kana": ""
}


func set_data(accent_phrases: Array = [], speed_scale: float = 0.0, pitch_scale: float = 0.0, intonation_scale: float = 0.0, volume_scale: float = 0.0, pre_phoneme_length: float = 0.0, post_phoneme_length: float = 0.0, pause_length: Variant = null, pause_length_scale: float = 0.0, output_sampling_rate: float = 0.0, output_stereo: bool = false, kana: String = "") -> void:
	data = {
		"accent_phrases": accent_phrases,
		"speedScale": speed_scale,
		"pitchScale": pitch_scale,
		"intonationScale": intonation_scale,
		"volumeScale": volume_scale,
		"prePhonemeLength": pre_phoneme_length,
		"postPhonemeLength": post_phoneme_length,
		"pauseLength": pause_length,
		"pauseLengthScale": pause_length_scale,
		"outputSamplingRate": output_sampling_rate,
		"outputStereo": output_stereo,
		"kana": kana
	}


func get_data() -> Dictionary:
	return data
