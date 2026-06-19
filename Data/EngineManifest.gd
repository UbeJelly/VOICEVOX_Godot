class_name EngineManifest extends Node


@export var data: Dictionary = {
	"manifest_version": "",
	"name": "",
	"brand_name": "",
	"uuid": "",
	"url": "",
	"icon": "",
	"default_sampling_rate": 0,
	"frame_rate": 0,
	"terms_of_service": "",
	"update_infos": [
		{
			"version": "",
			"descriptions": [ "" ],
			"contributors": [ "" ]
		}
	],
	"dependency_licenses": [
		{
			"name": "",
			"version": "",
			"license": "",
			"text": ""
		}
	],
	"supported_vvlib_manifest_version": "",
	"supported_features": {
		"adjust_mora_pitch": true,
		"adjust_phoneme_length": true,
		"adjust_speed_scale": true,
		"adjust_pitch_scale": true,
		"adjust_intonation_scale": true,
		"adjust_volume_scale": true,
		"adjust_pause_length": true,
		"interrogative_upspeak": true,
		"synthesis_morphing": true,
		"sing": true,
		"manage_library": true,
		"return_resource_url": true,
		"apply_katakana_english": true
	}
}


func set_data(_data: Dictionary = {}) -> void:
	data = _data


func get_data() -> Dictionary:
	return data
