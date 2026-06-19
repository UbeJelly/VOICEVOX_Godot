class_name VOICEVOXClient extends HTTPRequest

#region Variables
enum Get {
	ACCENT_PHRASES,
	ADD_PRESET,
	AUDIO_QUERY,
	AUDIO_QUERY_FROM_PRESET,
	CANCELLABLE_SYNTHESIS,
	CORE_VERSIONS,
	CONNECT_WAVES,
	DELETE_PRESET,
	ENGINE_MANIFEST,
	FRAME_SYNTHESIS,
	INITIALIZE_SPEAKER,
	IS_INITIALIZED_SPEAKER,
	MORA_DATA,
	MORA_LENGTH,
	MORA_PITCH,
	MORPHABLE_TARGETS,
	MULTI_SYNTHESIS,
	PARSE_KANA_BAD_REQUEST,
	PRESET,
	PRESETS,
	SCORE,
	SING_FRAME_AUDIO_QUERY,
	SING_FRAME_F0,
	SING_FRAME_VOLUME,
	SINGERS,
	SINGER_INFO,
	SPEAKER_INFO,
	SPEAKERS,
	SUPPORTED_DEVICES,
	SYNTHESIS,
	SYNTHESIS_MORPHING,
	UPDATE_PRESET,
	VALIDATE_KANA,
	VERSION,
}

const listens: Dictionary = { "host": "127.0.0.1", "port": "50021" }
const headers: Dictionary = { "header": "Content-Type: application/json", "accept": "Accept: application/json" }

## INFO: Speaker like who's talking, how fast they talk, how much pitch they have, etc.
@export_category("VOICEVOX Speaker")
@export_range(0, 999) var speaker: int = 3 												## The id of the Speaker.
@export_range(0.5, 2.0, 0.05, "prefer_slider") var speed_scale: float = 1.0 			## The speed how fast the Speaker talks.
@export_range(-0.15, 0.15, 0.01, "prefer_slider") var pitch_scale: float = 0.0 			## The perceived highness or lowness of a sound.
@export_range(0.0, 2.0, 0.05, "prefer_slider") var intonation_scale: float = 1.0 		## The rise and fall of voice in speech.
@export_range(0.0, 2.0, 0.05, "prefer_slider") var volume_scale: float = 2.0			## The perceived loudness or intensity of a sound.
@export_range(0.0, 1.5, 0.01, "prefer_slider") var pre_phoneme_length: float = 0.1		## The silent duration before the audio (e.g., the 'k' in 'ka').
@export_range(0.0, 1.5, 0.01, "prefer_slider") var post_phoneme_length: float = 0.1 	## The silent duration after the audio.

## INFO: Settings for the audio player. This affects the entire settings of the Speaker.
@export_category("AudioStreamPlayer")
@export_range(0.0, 1.0, 0.1, "prefer_slider") var stream_volume: float = 1.0			## The volume when the audio is played by AudioStreamPlayer.
@export_range(16000.0, 48000.0, 1000.0) var stream_sample_rate: float = 24000.0			## The mix rate when the audio is played by AudioStreamPlayer.

## INFO: Toggle the visibility of callback status or requested data on terminal.
@export_category("Console Texts")
@export var print_stat: bool = true			## Show or hide the status of functions.
@export var print_data: bool = true			## Show or hide the requested data.
@export var print_result: bool = true		## Show or hide the result of requests.
@export var print_response: bool = true		## Show or hide the response of requests.

var url: String = "http://{host}:{port}".format(listens)
var query: int = 0

## INFO: Schemas - the data containers for POST and GET requests
@onready var accent_phrases := AccentPhrases.new()
@onready var added_preset := AddPreset.new()
@onready var audio_query := AudioQuery.new()
@onready var audio_query_from_preset := AudioQueryFromPreset.new()
@onready var cancellable_synthesis := CancellableSynthesis.new()
@onready var core_versions := CoreVersions.new()
@onready var engine_manifest := EngineManifest.new()
@onready var frame_audio_query := FrameAudioQuery.new()
@onready var http_validation_error := HTTPValidationError.new()
@onready var initialized_speaker := InitializedSpeaker.new()
@onready var mora := Mora.new()
@onready var mora_length := MoraLength.new()
@onready var mora_pitch := MoraPitch.new()
@onready var morphable_targets := MorphableTargets.new()
@onready var multi_synthesis := MultiSynthesis.new()
@onready var parse_kana_bad_request := ParseKanaBadRequest.new()
@onready var presets := Presets.new()
@onready var score := Score.new()
@onready var sing_frame_f0 := SingFrameF0.new()
@onready var sing_frame_volume := SingFrameVolume.new()
@onready var singers := Singers.new()
@onready var singer_info := SingerInfo.new() 
@onready var speaker_info := SpeakerInfo.new()
@onready var speakers := Speakers.new()
@onready var supported_devices_info := SupportedDevicesInfo.new()
@onready var synthesis := Synthesis.new()
@onready var synthesis_morphing := SynthesisMorphing.new()
@onready var updated_preset := UpdatePreset.new()
@onready var validate_kana := ValidateKana.new()
@onready var version := Version.new()

## INFO: Sub nodes
@onready var audio_stream_player := $AudioStreamPlayer
#endregion

func _ready() -> void:
	set_speech_settings(3, 1.15, 0.05, 1.45, 2.0, 0.1, 0.1)
	text_to_speech("Hello world! This is voice box gee doh. It's nice to meet you!")

#region Main Client Functions
## The Text-to-Speech function. It posts an [param audio_query] and synthesizes its data with [param synthesis()] function.
## [param text] is the text to synthesize to speech.
func text_to_speech(text: String) -> void:
	post_audio_query(text, speaker)
	await request_completed
	if not audio_query.get_data().is_empty():
		post_synthesis(audio_query.get_data())
		await request_completed
	else:
		if print_stat == true:
			print("❌ text_to_speech() failed.")


## The Text-to-Speech function. It posts an [param audio_query] and synthesizes its data with [param synthesis()] function.
## [param text] is the text to synthesize to speech.
## [param preset_id] is the id of a preset to use.
func text_to_speech_from_preset(text: String, preset_id: int) -> void:
	post_audio_query_from_preset(text, preset_id)
	await request_completed
	if not audio_query_from_preset.get_data().is_empty():
		post_synthesis(audio_query_from_preset.get_data())
		await request_completed
	else:
		if print_stat == true:
			print("❌ text_to_speech_from_preset() failed.")


## Modifies the settings of the Speaker. It affects how the synthesized speech is spoken.
## Call this before the text_to_speech() function to change the default values for query.
## [param speaker_id] is the id of the Speaker.
## [param speed] is the speed how fast the Speaker talks.
## [param pitch] is the perceived highness or lowness of a sound.
## [param intonation] is the rise and fall of voice in speech.
## [param volume] is the perceived loudness or intensity of a sound.
## [param pre_phoneme_duration] is the speed how fast the Speaker talks.
## [param post_phoneme_duration] is the speed how fast the Speaker talks.
func set_speech_settings(speaker_id: int = 3, speed: float = 1.0, pitch: float = 0.0, intonation: float = 1.0, volume: float = 2.0, pre_phoneme_duration: float = 0.1, post_phoneme_duration: float = 0.1) -> void:
	speaker = speaker_id
	speed_scale = speed
	pitch_scale = pitch
	intonation_scale = intonation
	volume_scale = volume
	pre_phoneme_length = pre_phoneme_duration
	post_phoneme_length = post_phoneme_duration


## Changes the settings of the AudioStreamPlayer. It affects how the overall audio sounds when played.
## [param volume] is the entire volume when the audio is played.
func set_audio_play_settings(volume: float = 1.0) -> void:
	stream_volume = volume
#endregion

#region Main VOICEVOX API Calls
## Requests the available speakers. Receives an Array after request_completed.
func get_speakers() -> void:
	query = Get.SPEAKERS
	var endpoint: String = url+"/speakers"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_speakers() run successfully.")
		else:
			print("❌ get_speakers() failed.")


## Set the initial values for speech synthesis query. Receives a Dictionary after request_completed.
## [param text] is the text to be spoken by a speech synthesis query.
## [param speaker_id] is the id of the speaker that will talk.
func post_audio_query(text: String, speaker_id: int) -> void:
	query = Get.AUDIO_QUERY
	var params: Dictionary = { "text": text.uri_encode(), "speaker": speaker_id }
	var endpoint: String = url+"/audio_query?text={text}&speaker={speaker}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if print_stat == true:
		if error == OK:
			print("✓ post_audio_query() run successfully.")
		else:
			print("❌ post_audio_query() failed.")


## Synthesizes the data from audio query. Receives a PackedByteArray after request_completed.
## [param audio_query_data] is the data to synthesize speech with.
func post_synthesis(audio_query_data: Dictionary) -> void:
	query = Get.SYNTHESIS
	var params: Dictionary = { "speaker": speaker }
	var endpoint: String = url+"/synthesis?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(audio_query_data)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_synthesis() run successfully.")
		else:
			print("❌ post_synthesis() failed.")
#endregion

#region VOICEVOX API Calls
## Create a speech synthesis query using presets. Presets must not be empty. Use [param post_add_preset()] to add a preset, while [param get_presets()] to get an array of presets.
## [param text] is the text to be spoken by a speech synthesis query.
## [param preset_id] is the id of a preset to use.
func post_audio_query_from_preset(text: String, preset_id: int) -> void:
	query = Get.AUDIO_QUERY_FROM_PRESET
	var params: Dictionary = { "text": text.uri_encode(), "preset": preset_id }
	var endpoint: String = url+"/audio_query_from_preset?text={text}&preset_id={preset}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if print_stat == true:
		if error == OK:
			print("✓ post_audio_query_from_preset() run successfully.")
		else:
			print("❌ post_audio_query_from_preset() failed.")


## Extracts the accents of phrases from the text.
## [param text] is the text to be spoken by a speech synthesis query.
## [param speaker_id] is the id of the speaker that will talk.
func post_accent_phrases(text: String, speaker_id: int) -> void:
	query = Get.ACCENT_PHRASES
	var params: Dictionary = { "text": text.uri_encode(), "speaker": speaker_id }
	var endpoint: String = url+"/accent_phrases?text={text}&speaker={speaker}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if print_stat == true:
		if error == OK:
			print("✓ post_accent_phrases() run successfully.")
		else:
			print("❌ post_accent_phrases() failed.")


## Synthesizes the data from cancelable audio query. Receives a PackedByteArray after request_completed.
## [param audio_query_data] is the data to synthesize speech with.
func post_cancellable_synthesis(audio_query_data: Dictionary) -> void:
	query = Get.CANCELLABLE_SYNTHESIS
	var params: Dictionary = { "speaker": speaker }
	var endpoint: String = url+"/cancellable_synthesis?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(audio_query_data)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_cancellable_synthesis() run successfully.")
		else:
			print("❌ post_cancellable_synthesis() failed.")


## Synthesizes the data from frame audio query. Receives a PackedByteArray after request_completed.
## [param frame_audio_query_data] is a Dictionary of FrameAudioQuery to synthesize speech from.
func post_frame_synthesis(frame_audio_query_data: Dictionary) -> void:
	query = Get.FRAME_SYNTHESIS
	var params: Dictionary = { "speaker": speaker }
	var endpoint: String = url+"/frame_synthesis?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(frame_audio_query_data)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_frame_synthesis() run successfully.")
		else:
			print("❌ post_frame_synthesis() failed.")


## Get phoneme length and pitch from accent phrases.
## [param speaker_id] is the id of the speaker that will talk.
## [param accent_phrases_data] is the returned Array from AccentPhrases.
func post_mora_data(speaker_id: int, accent_phrases_data: Array) -> void:
	query = Get.MORA_DATA
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/mora_data?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(accent_phrases_data)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_mora_data() run successfully.")
		else:
			print("❌ post_mora_data() failed.")


## Get phoneme lengths from accent phrases.
## [param speaker_id] is the id of the speaker that will talk.
## [param accent_phrases_data] is the returned Array from AccentPhrases.
func post_mora_length(speaker_id: int, accent_phrases_data: Array) -> void:
	query = Get.MORA_LENGTH
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/mora_length?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(accent_phrases_data)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_mora_length() run successfully.")
		else:
			print("❌ post_mora_length() failed.")


## Get phoneme pitch from accent phrases.
## [param speaker_id] is the id of the speaker that will talk.
## [param accent_phrases_data] is the returned Array from AccentPhrases.
func post_mora_pitch(speaker_id: int, accent_phrases_data: Array) -> void:
	query = Get.MORA_PITCH
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/mora_pitch?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(accent_phrases_data)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_mora_pitch() run successfully.")
		else:
			print("❌ post_mora_pitch() failed.")


## Checks if characters in the engine can morph for a specified style.
## [param base_style_ids] is an array of base style ids that can morph.
func post_morphable_targets(base_style_ids: PackedInt32Array) -> void:
	query = Get.MORPHABLE_TARGETS
	var endpoint: String = url+"/morphable_targets"
	var request_body: String = JSON.stringify(base_style_ids)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_morphable_targets() run successfully.")
		else:
			print("❌ post_morphable_targets() failed.")


## Synthesizes the data from audio query. Receives a PackedByteArray after request_completed.
## [param multi_audio_query_data] is an Array of multiple AudioQuery to synthesize speech from.
func post_multi_synthesis(multi_audio_query_data: Array) -> void:
	query = Get.MULTI_SYNTHESIS
	var params: Dictionary = { "speaker": speaker }
	var endpoint: String = url+"/multi_synthesis?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(multi_audio_query_data)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_multi_synthesis() run successfully.")
		else:
			print("❌ post_multi_synthesis() failed.")


## Obtains the initial values ​​for the query used for singing voice synthesis.
## [param speaker_id] is the id of the speaker that will talk.
## [param score_data] is the returned data from Score.
func post_sing_frame_audio_query(speaker_id: int, score_data: Dictionary) -> void:
	query = Get.SING_FRAME_AUDIO_QUERY
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/sing_frame_audio_query?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(score_data)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_sing_frame_audio_query() run successfully.")
		else:
			print("❌ post_sing_frame_audio_query() failed.")


## Get the basic frequency for each frame from queries for sheet music and singing voice synthesis.
## [param speaker_id] is the id of the speaker that will talk.
## [param score_data] is the returned data from Score.
## [param frame_audio_query_data] is the returned data from FrameAudioQuery.
func post_sing_frame_f0(speaker_id: int, score_data: Dictionary, frame_audio_query_data: Dictionary) -> void:
	query = Get.SING_FRAME_F0
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/sing_frame_f0?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(
		{ "score": score_data, "frame_audio_query": frame_audio_query_data }
	)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_sing_frame_f0() run successfully.")
		else:
			print("❌ post_sing_frame_f0() failed.")


## Get per-frame volume from queries for sheet music and vocal synthesis
## [param speaker_id] is the id of the speaker that will talk.
## [param score_data] is the returned data from Score.
## [param frame_audio_query_data] is the returned data from FrameAudioQuery.
func post_sing_frame_volume(speaker_id: int, score_data: Dictionary, frame_audio_query_data: Dictionary) -> void:
	query = Get.SING_FRAME_VOLUME
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/sing_frame_volume?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(
		{ "score": score_data, "frame_audio_query": frame_audio_query_data }
	)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_sing_frame_volume() run successfully.")
		else:
			print("❌ post_sing_frame_volume() failed.")


## Synthesize voice in two specified styles and obtain a voice morphed at a specified ratio.
## [param base_speaker] is the id of the speaker that will be morphed.
## [param target_speaker] is the id of another speaker to morph from.
## [param morph_rate] is the rate of morph from 0 to 1.
## [param audio_query_data] is the data to synthesize speech with.
func post_synthesis_morphing(base_speaker: int, target_speaker: int, morph_rate: float, audio_query_data: Dictionary) -> void:
	query = Get.SYNTHESIS_MORPHING
	var params: Dictionary = { "base_speaker ": base_speaker, "target_speaker": target_speaker, "morph_rate": morph_rate }
	var endpoint: String = url+"/synthesis_morphing?base_speaker={base_speaker}&target_speaker={target_speaker}&morph_rate={morph_rate}".format(params)
	var request_body: String = JSON.stringify(audio_query_data)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_synthesis_morphing() run successfully.")
		else:
			print("❌ post_synthesis_morphing() failed.")


## Opens the portal to the default browser if listening to the host and port.
func open_portal() -> void:
	var error: int = OS.shell_open(url)
	if print_stat == true:
		if error == OK:
			print("Opened portal on browser.\n")
		else:
			print("Cannot open portal. Check host and port.\n")
#endregion

#region Other VOICEVOX API Calls
## Merge multiple WAV data encoded with base64 into one.
## [param waves] are the multiple WAV data encoded with base64.
func post_connect_waves(waves: PackedStringArray) -> void:
	query = Get.CONNECT_WAVES
	var endpoint: String = url+"/connect_waves"
	var request_body: String = JSON.stringify(waves)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_connect_waves() run successfully.")
		else:
			print("❌ post_connect_waves() failed.")


## Checks whether the text follows AquesTalk wind transcription. If you do not follow this, error would occur.
## [param text] is the text to validate kana from.
func post_validate_kana(text: String) -> void:
	query = Get.VALIDATE_KANA
	var params: Dictionary = { "text": text.uri_encode() }
	var endpoint: String = url+"/validate_kana?text={text}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if print_stat == true:
		if error == OK:
			print("✓ post_validate_kana() run successfully.")
		else:
			print("❌ post_validate_kana() failed.")


## Initialize the specified style. Other APIs can be used without running, but the initial runtime may take some time.
## [param speaker_id] is the id of the speaker that will talk.
## [param skip_reinit] to skip reinitializing styles that have already been initialized.
func post_initialize_speaker(speaker_id: int, skip_reinit: bool = false) -> void:
	query = Get.INITIALIZE_SPEAKER
	var params: Dictionary = { "speaker": speaker_id, "skip_reinit": skip_reinit }
	var endpoint: String = url+"/initialize_speaker?speaker={speaker}&skip_reinit={skip_reinit}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if print_stat == true:
		if error == OK:
			print("✓ post_initialize_speaker() run successfully.")
		else:
			print("❌ post_initialize_speaker() failed.")


## Returns whether the specified style has been initialized.
## [param speaker_id] is the id of the speaker that will talk.
func is_initialized_speaker(speaker_id: int) -> void:
	query = Get.IS_INITIALIZED_SPEAKER
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/is_initialized_speaker?speaker={speaker}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ is_initialized_speaker() run successfully.")
		else:
			print("❌ is_initialized_speaker() failed.")


## Get a list of supported devices.
func get_supported_devices() -> void:
	query = Get.SUPPORTED_DEVICES
	var endpoint: String = url+"/supported_devices"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_supported_devices() run successfully.")
		else:
			print("❌ get_supported_devices() failed.")


## Get the preset settings used by the engine.
func get_presets() -> void:
	query = Get.PRESETS
	var endpoint: String = url+"/presets"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_presets() run successfully.")
		else:
			print("❌ get_presets() failed.")


## Add a new preset.
## [param id] is the id of the new preset.
## [param _name] is the name of the new preset. 
## [param speaker_uuid] is the UUID of the speaker.
## [param style_id] is the style id of the new preset.
## [param _speed_scale] is the speed how fast the Speaker talks.
## [param _pitch_scale] is the perceived highness or lowness of a sound.
## [param _intonation_scale] is the rise and fall of voice in speech.
## [param _volume_scale] is the perceived loudness or intensity of a sound.
## [param _pre_phoneme_length] is the silent duration before the audio (e.g., the 'k' in 'ka').
## [param _post_phoneme_length] is the silent duration after the audio.
## [param pause_length]
## [param pause_length_scale]
func add_preset(id: int, _name: String, speaker_uuid: String, style_id: int, _speed_scale: float, _pitch_scale: float, _intonation_scale: float, _volume_scale: float, _pre_phoneme_length: float, _post_phoneme_length: float, pause_length: float, pause_length_scale: float) -> void:
	query = Get.ADD_PRESET
	var endpoint: String = url+"/add_preset"
	var request_body: String = JSON.stringify({
		"id": id,
		"name": _name,
		"speaker_uuid": speaker_uuid,
		"style_id": style_id,
		"speedScale": _speed_scale,
		"pitchScale": _pitch_scale,
		"intonationScale": _intonation_scale,
		"volumeScale": _volume_scale,
		"prePhonemeLength": _pre_phoneme_length,
		"postPhonemeLength": _post_phoneme_length,
		"pauseLength": pause_length,
		"pauseLengthScale": pause_length_scale
	})

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ add_preset() run successfully.")
		else:
			print("❌ add_preset() failed.")


## Update existing presets.
## [param id] is the id of the new preset.
## [param _name] is the name of the new preset. 
## [param speaker_uuid] is the UUID of the speaker.
## [param style_id] is the style id of the new preset.
## [param _speed_scale] is the speed how fast the Speaker talks.
## [param _pitch_scale] is the perceived highness or lowness of a sound.
## [param _intonation_scale] is the rise and fall of voice in speech.
## [param _volume_scale] is the perceived loudness or intensity of a sound.
## [param _pre_phoneme_length] is the silent duration before the audio (e.g., the 'k' in 'ka').
## [param _post_phoneme_length] is the silent duration after the audio.
## [param pause_length]
## [param pause_length_scale]
func update_preset(id: int, _name: String, speaker_uuid: String, style_id: int, _speed_scale: float, _pitch_scale: float, _intonation_scale: float, _volume_scale: float, _pre_phoneme_length: float, _post_phoneme_length: float, pause_length: float, pause_length_scale: float) -> void:
	query = Get.UPDATE_PRESET
	var endpoint: String = url+"/update_preset"
	var request_body: String = JSON.stringify({
		"id": id,
		"name": _name,
		"speaker_uuid": speaker_uuid,
		"style_id": style_id,
		"speedScale": _speed_scale,
		"pitchScale": _pitch_scale,
		"intonationScale": _intonation_scale,
		"volumeScale": _volume_scale,
		"prePhonemeLength": _pre_phoneme_length,
		"postPhonemeLength": _post_phoneme_length,
		"pauseLength": pause_length,
		"pauseLengthScale": pause_length_scale
	})

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ update_preset() run successfully.")
		else:
			print("❌ update_preset() failed.")


## Delete existing presets.
## [param id] is the id of the preset to delete.
func delete_preset(id: int) -> void:
	query = Get.DELETE_PRESET
	var params: Dictionary = { "id": id }	
	var endpoint: String = url+"/delete_preset?id={id}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if print_stat == true:
		if error == OK:
			print("✓ delete_preset() run successfully.")
		else:
			print("❌ delete_preset() failed.")


## Returns information about the speaking character specified by UUID. Images and audio are returned in the format specified by the resource_format.
## [param speaker_uuid] is the UUID of the speaker.
## [param resource_format] is the format of the resource. Available values: base64, url.
func get_speaker_info(speaker_uuid: String, resource_format: String = "base64") -> void:
	query = Get.SPEAKER_INFO
	var params: Dictionary = { "speaker_uuid": speaker_uuid, "resource_format": resource_format }
	var endpoint: String = url+"/speaker_info?speaker_uuid={speaker_uuid}&resource_format={resource_format}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_speaker_info() run successfully.")
		else:
			print("❌ get_speaker_info() failed.")


## Returns a list of singable characters.
func get_singers() -> void:
	query = Get.SINGERS
	var endpoint: String = url+"/singers"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_singers() run successfully.")
		else:
			print("❌ get_singers() failed.")


## Returns information about the singable character specified by UUID. Images and audio are returned in the format specified by the resource_format.
## [param speaker_uuid] is the UUID of the speaker.
## [param resource_format] is the format of the resource. Available values: base64, url.
func get_singer_info(speaker_uuid: String, resource_format: String = "base64") -> void:
	query = Get.SINGER_INFO
	var params: Dictionary = { "speaker_uuid": speaker_uuid, "resource_format": resource_format }
	var endpoint: String = url+"/singer_info?speaker_uuid={speaker_uuid}&resource_format={resource_format}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_singers_info() run successfully.")
		else:
			print("❌ get_singers_info() failed.")


## Get the engine version.
func get_version() -> void:
	query = Get.VERSION
	var endpoint: String = url+"/version"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_version() run successfully.")
		else:
			print("❌ get_version() failed.")


## Get a list of available core versions.
func get_core_versions() -> void:
	query = Get.CORE_VERSIONS
	var endpoint: String = url+"/core_versions"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_core_versions() run successfully.")
		else:
			print("❌ get_core_versions() failed.")


## Get the engine manifesto.
func get_engine_manifest() -> void:
	query = Get.ENGINE_MANIFEST
	var endpoint: String = url+"/engine_manifest"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if print_stat == true:
		if error == OK:
			print("✓ get_engine_manifest() run successfully.")
		else:
			print("❌ get_engine_manifest() failed.")
#endregion

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data: Variant = null

	if print_result == true:
		if result == RESULT_SUCCESS:
			print("✓ HTTP request result code: %s" % _get_result(result))
		else:
			print("❌ HTTP request failed. Error: %s" % _get_result(result))
	
	if response_code == HTTPClient.RESPONSE_OK:
		if print_response == true:
			print("✓ HTTP request response code: %s\n" % _get_response(response_code))

		match query:
			Get.SPEAKERS:
				data = _parse_JSON(body)
				speakers.set_data(data)

			Get.AUDIO_QUERY:
				data = _parse_JSON(body)
				audio_query.set_data(
					data["accent_phrases"],
					intonation_scale,
					data["kana"],
					data["outputSamplingRate"],
					data["outputStereo"],
					data["pauseLength"],
					data["pauseLengthScale"],
					pitch_scale,
					post_phoneme_length,
					pre_phoneme_length,
					speed_scale,
					volume_scale
				)

			Get.SYNTHESIS:
				_play_WAV_file(body)

			Get.ACCENT_PHRASES:
				data = _parse_JSON(body)
				accent_phrases.set_data(data)

			Get.ADD_PRESET:
				data = _parse_JSON(body)
				added_preset.set_data(data)

			Get.AUDIO_QUERY_FROM_PRESET:
				data = _parse_JSON(body)
				audio_query_from_preset.set_data(
					data["accent_phrases"],
					data["speedScale"],
					data["pitchScale"],
					data["intonationScale"],
					data["volumeScale"],
					data["prePhonemeLength"],
					data["postPhonemeLength"],
					data["pauseLength"],
					data["pauseLengthScale"],
					data["outputSamplingRate"],
					data["outputStereo"],
					data["kana"]
				)

			Get.CANCELLABLE_SYNTHESIS:
				_play_WAV_file(body)

			Get.CORE_VERSIONS:
				data = _parse_JSON(body)
				core_versions.set_data(data)

			Get.CONNECT_WAVES:
				_play_WAV_file(body)

			Get.ENGINE_MANIFEST:
				data = _parse_JSON(body)
				engine_manifest.set_data(data)

			Get.FRAME_SYNTHESIS:
				_play_WAV_file(body)

			Get.IS_INITIALIZED_SPEAKER:
				data = _parse_JSON(body)
				initialized_speaker.set_data(data)

			Get.MORA_DATA:
				data = _parse_JSON(body)
				mora.set_data(data)

			Get.MORA_LENGTH:
				data = _parse_JSON(body)
				mora_length.set_data(data)

			Get.MORA_PITCH:
				data = _parse_JSON(body)
				mora_pitch.set_data(data)

			Get.MORPHABLE_TARGETS:
				data = _parse_JSON(body)
				morphable_targets.set_data(data)

			Get.MULTI_SYNTHESIS:
				_play_WAV_file(body)

			Get.PRESETS:
				data = _parse_JSON(body)
				presets.set_data(data)

			Get.SCORE:
				data = _parse_JSON(body)
				score.set_data(data)

			Get.SING_FRAME_AUDIO_QUERY:
				data = _parse_JSON(body)
				frame_audio_query.set_data(
					data["f0"],
					data["volume"],
					data["phonemes"],
					data["volumeScale"],
					data["outputSamplingRate"],
					data["outputStereo"]
				)

			Get.SING_FRAME_F0:
				data = _parse_JSON(body)
				sing_frame_f0.set_data(data)

			Get.SING_FRAME_VOLUME:
				data = _parse_JSON(body)
				sing_frame_volume.set_data(data)

			Get.SINGERS:
				data = _parse_JSON(body)
				singers.set_data(data)

			Get.SINGER_INFO:
				data = _parse_JSON(body)
				singer_info.set_data(data)

			Get.SPEAKER_INFO:
				data = _parse_JSON(body)
				speaker_info.set_data(data)

			Get.SUPPORTED_DEVICES:
				data = _parse_JSON(body)
				supported_devices_info.set_data(data)

			Get.SYNTHESIS_MORPHING:
				_play_WAV_file(body)

			Get.UPDATE_PRESET:
				data = _parse_JSON(body)
				updated_preset.set_data(data)

			Get.VALIDATE_KANA:
				data = _parse_JSON(body)
				validate_kana.set_data(data)

			Get.VERSION:
				data = _parse_JSON(body)
				version.set_data(data)

	else:
		if print_response == true:
			print("❌ HTTP request response code: %s\n" % _get_response(response_code))
		if response_code == HTTPClient.RESPONSE_NO_CONTENT:
			match query:
				Get.INITIALIZE_SPEAKER:
					print("Initialized speaker. No content to receive.")
				Get.DELETE_PRESET:
					print("Deleted preset. No content to receive.")
		if response_code == HTTPClient.RESPONSE_BAD_REQUEST:			
			if query == Get.VALIDATE_KANA:
				data = _parse_JSON(body)
				parse_kana_bad_request.set_data(data)
		elif response_code == HTTPClient.RESPONSE_UNPROCESSABLE_ENTITY:	
			data = _parse_JSON(body)
			http_validation_error.set_data(data)

#region Other Functions
## Opens the docs to the default browser if listening to the host and port.
func open_docs() -> void:
	var error: int = OS.shell_open(url+"/docs".format(url))
	if print_stat == true:
		if error == OK:
			print("Opened documentation on browser.\n")
		else:
			print("Cannot open documentation. Check host and port.\n")


## Plays the WAV file from speech synthesis via post_synthesis.
## [param wav_data] the packed array of bytes which will be read as WAV.
func _play_WAV_file(wav_data: PackedByteArray) -> void:
	var sample_rate: float = stream_sample_rate

	var stream = AudioStreamWAV.new()
	stream.data = wav_data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false

	audio_stream_player.stream = stream
	audio_stream_player.volume_linear = stream_volume
	audio_stream_player.play()


## Parses JSON and returns as Array or Dictionary.
## [param body] is the received object from a completed request.
func _parse_JSON(body: PackedByteArray) -> Variant:
	var json := JSON.new()
	var string: String = body.get_string_from_utf8()
	var error: int = json.parse(string)

	if error == OK:
		var data_got: Variant = json.data
		if typeof(data_got) == TYPE_ARRAY or typeof(data_got) == TYPE_DICTIONARY:
			if print_data == true:
				print(JSON.stringify(data_got, "\t")+"\n")
			return data_got
		else:
			if print_data == true:
				print("❌ _parse_JSON() failed. Unexpected data.")
			return {}
	else:
		if print_data == true:
			print("❌ _parse_JSON() error: ", json.get_error_message(), " in ", string, " at line ", json.get_error_line(), ".")
		return {}


## Returns a readable result code in.
## [param id] is the result code/id.
func _get_result(id: int) -> String:
	var status: String = ""
	match id:
		0: status = "RESULT_SUCCESS"
		1: status = "RESULT_CHUNKED_BODY_SIZE_MISMATCH"
		2: status = "RESULT_CANT_CONNECT"
		3: status = "RESULT_CANT_RESOLVE"
		4: status = "RESULT_CONNECTION_ERROR"
		5: status = "RESULT_TLS_HANDSHAKE_ERROR"
		6: status = "RESULT_NO_RESPONSE"
		7: status = "RESULT_BODY_SIZE_LIMIT_EXCEEDED"
		8: status = "RESULT_BODY_DECOMPRESS_FAILED"
		9: status = "RESULT_REQUEST_FAILED"
		10: status = "RESULT_DOWNLOAD_FILE_CANT_OPEN"
		11: status = "RESULT_DOWNLOAD_FILE_WRITE_ERROR"
		12: status = "RESULT_REDIRECT_LIMIT_REACHED"
		13: status = "RESULT_TIMEOUT"
	return status


## Returns a readable response code.
## [param id] is the response code/id.
func _get_response(id: int) -> String:
	var status: String = ""
	match id:
		100: status = "RESPONSE_CONTINUE"
		101: status = "RESPONSE_SWITCHING_PROTOCOLS"
		102: status = "RESPONSE_PROCESSING"
		200: status = "RESPONSE_OK"
		201: status = "RESPONSE_CREATED"
		202: status = "RESPONSE_ACCEPTED"
		203: status = "RESPONSE_NON_AUTHORITATIVE_INFORMATION"
		204: status = "RESPONSE_NO_CONTENT"
		205: status = "RESPONSE_RESET_CONTENT"
		206: status = "RESPONSE_PARTIAL_CONTENT"
		207: status = "RESPONSE_MULTI_STATUS"
		208: status = "RESPONSE_ALREADY_REPORTED"
		226: status = "RESPONSE_IM_USED"
		300: status = "RESPONSE_MULTIPLE_CHOICES"
		301: status = "RESPONSE_MOVED_PERMANENTLY"
		302: status = "RESPONSE_FOUND"
		303: status = "RESPONSE_SEE_OTHER"
		304: status = "RESPONSE_NOT_MODIFIED"
		305: status = "RESPONSE_USE_PROXY"
		306: status = "RESPONSE_SWITCH_PROXY"
		307: status = "RESPONSE_TEMPORARY_REDIRECT"
		308: status = "RESPONSE_PERMANENT_REDIRECT"
		400: status = "RESPONSE_BAD_REQUEST"
		401: status = "RESPONSE_UNAUTHORIZED"
		402: status = "RESPONSE_PAYMENT_REQUIRED"
		403: status = "RESPONSE_FORBIDDEN"
		404: status = "RESPONSE_NOT_FOUND"
		405: status = "RESPONSE_METHOD_NOT_ALLOWED"
		406: status = "RESPONSE_NOT_ACCEPTABLE"
		407: status = "RESPONSE_PROXY_AUTHENTICATION_REQUIRED"
		408: status = "RESPONSE_REQUEST_TIMEOUT"
		409: status = "RESPONSE_CONFLICT"
		410: status = "RESPONSE_GONE"
		411: status = "RESPONSE_LENGTH_REQUIRED"
		412: status = "RESPONSE_PRECONDITION_FAILED"
		413: status = "RESPONSE_REQUEST_ENTITY_TOO_LARGE"
		414: status = "RESPONSE_REQUEST_URI_TOO_LONG"
		415: status = "RESPONSE_UNSUPPORTED_MEDIA_TYPE"
		416: status = "RESPONSE_REQUESTED_RANGE_NOT_SATISFIABLE"
		417: status = "RESPONSE_EXPECTATION_FAILED"
		418: status = "RESPONSE_IM_A_TEAPOT"
		421: status = "RESPONSE_MISDIRECTED_REQUEST"
		422: status = "RESPONSE_UNPROCESSABLE_ENTITY"
		423: status = "RESPONSE_LOCKED"
		424: status = "RESPONSE_FAILED_DEPENDENCY"
		426: status = "RESPONSE_UPGRADE_REQUIRED"
		428: status = "RESPONSE_PRECONDITION_REQUIRED"
		429: status = "RESPONSE_TOO_MANY_REQUESTS"
		431: status = "RESPONSE_REQUEST_HEADER_FIELDS_TOO_LARGE"
		451: status = "RESPONSE_UNAVAILABLE_FOR_LEGAL_REASONS"
		500: status = "RESPONSE_INTERNAL_SERVER_ERROR"
		501: status = "RESPONSE_NOT_IMPLEMENTED"
		502: status = "RESPONSE_BAD_GATEWAY"
		503: status = "RESPONSE_SERVICE_UNAVAILABLE"
		504: status = "RESPONSE_GATEWAY_TIMEOUT"
		505: status = "RESPONSE_HTTP_VERSION_NOT_SUPPORTED"
		506: status = "RESPONSE_VARIANT_ALSO_NEGOTIATES"
		507: status = "RESPONSE_INSUFFICIENT_STORAGE"
		508: status = "RESPONSE_LOOP_DETECTED"
		510: status = "RESPONSE_NOT_EXTENDED"
		511: status = "RESPONSE_NETWORK_AUTH_REQUIRED"
	return status
#endregion
