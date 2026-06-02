class_name VOICEVOXClient extends HTTPRequest

enum Get {
	AUDIO_QUERY,
	AUDIO_QUERY_FROM_PRESET,
	SING_FRAME_AUDIO_QUERY,
	ACCENT_PHRASES,
	SPEAKERS,
	SYNTHESIS,
	SCORE
}

const listens: Dictionary = { "host": "127.0.0.1", "port": "50021" }
const headers: Dictionary = { "header": "Content-Type: application/json", "accept": "Accept: application/json" }

## INFO: Speaker like who's talking, how fast they talk, how much pitch they have, etc.
@export_category("VOICEVOX Speaker")
@export_range(0, 999) var speaker: int = 3 											## The id of the Speaker.
@export_range(0.5, 2.0, 0.05, "prefer_slider") var speed_scale: float = 1.0 		## The speed how fast the Speaker talks.
@export_range(-0.15, 0.15, 0.01, "prefer_slider") var pitch_scale: float = 0.0 		## The perceived highness or lowness of a sound.
@export_range(0.0, 2.0, 0.05, "prefer_slider") var intonation_scale: float = 1.0 	## The rise and fall of voice in speech.
@export_range(0.0, 2.0, 0.05, "prefer_slider") var volume_scale: float = 2.0		## The perceived loudness or intensity of a sound.
@export_range(0.0, 1.5, 0.01, "prefer_slider") var pre_phoneme_length: float = 0.1	## The silent duration before the audio (e.g., the 'k' in 'ka').
@export_range(0.0, 1.5, 0.01, "prefer_slider") var post_phoneme_length: float = 0.1 ## The silent duration after the audio.

## INFO: Settings for the audio player. This affects the entire settings of the Speaker.
@export_category("AudioStreamPlayer")
@export_range(0.0, 1.0, 0.1, "prefer_slider") var stream_volume: float = 1.0		## The entire volume when the audio is played.

## INFO: Toggle the visibility of callback status or requested data on terminal.
@export_category("Console Texts")
@export var print_stat: bool = true			## Show or hide the status of functions.
@export var print_data: bool = true			## Show or hide the requested data.
@export var print_result: bool = true		## Show or hide the result of requests.
@export var print_response: bool = true		## Show or hide the response of requests.

var url: String = "http://{host}:{port}".format(listens)
var query: int = 0

## INFO: Schemas - the data containers for POST and GET requests
@onready var audio_query := AudioQuery.new()
@onready var audio_query_from_preset := AudioQueryFromPreset.new()
@onready var frame_audio_query := FrameAudioQuery.new()
@onready var accent_phrases := AccentPhrases.new()
@onready var synthesis := Synthesis.new()
@onready var speakers := Speakers.new()
@onready var http_validation_error := HTTPValidationError.new()
@onready var score := Score.new()

@onready var audio_stream_player := $AudioStreamPlayer


func _ready() -> void:
	set_speech_settings(3, 1.15, 0.05, 1.45, 2.0, 0.1, 0.1)
	text_to_speech("Hello world! This is voice box gee doh. It's nice to meet you!")
	
	## TODO: Make and use both post_add_preset() and get_presets() first to see if it works.
	## Then proceed on using post_audio_query_from_preset() via text_to_speech_from_preset()
	
	#text_to_speech_from_preset("Hello world! I'm one of the presets!", 12)


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
			print("❌ text_to_speech() failed.")


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


## Obtains the initial values ​​for the query used for singing voice synthesis.
## [param speaker_id] is the id of the speaker that will talk.
## A [param Score] data is used on request body. 
func post_sing_frame_audio_query(speaker_id: int) -> void:
	query = Get.SING_FRAME_AUDIO_QUERY
	var params: Dictionary = { "speaker": speaker_id }
	var endpoint: String = url+"/sing_frame_audio_query?speaker={speaker}".format(params)
	var request_body: String = JSON.stringify(score.data)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST, request_body)
	if print_stat == true:
		if error == OK:
			print("✓ post_sing_frame_audio_query() run successfully.")
		else:
			print("❌ post_sing_frame_audio_query() failed.")


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


## Synthesizes the data from audio query. Receives a PackedByteArray after request_completed.
## [param audio_query_data] is the data to synthesize speech with.
func post_synthesis(audio_query_data: Dictionary) -> void:
	query = Get.SYNTHESIS
	var params: Dictionary = { "speaker": speaker }
	var endpoint: String = url+"/synthesis?speaker={speaker}".format(params)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, JSON.stringify(audio_query_data))
	if print_stat == true:
		if error == OK:
			print("✓ post_synthesis() run successfully.")
		else:
			print("❌ post_synthesis() failed.")


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

			Get.AUDIO_QUERY_FROM_PRESET:
				data._parse_JSON(body)
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

			Get.SING_FRAME_AUDIO_QUERY:
				data._parse_JSON(body)
				frame_audio_query.set_data(
					data["f0"],
					data["volume"],
					data["phonemes"],
					data["volumeScale"],
					data["outputSamplingRate"],
					data["outputStereo"]
				)

			Get.SCORE:
				data._parse_JSON(body)
				score.set_data(data)

	else:
		if print_response == true:
			print("❌ Validation Error! HTTP request response code: %s\n" % _get_response(response_code))
		data = _parse_JSON(body)
		http_validation_error.set_data(data)


## Opens the portal to the default browser if listening to the host and port.
func open_portal() -> void:
	var error: int = OS.shell_open(url)
	if print_stat == true:
		if error == OK:
			print("Opened portal on browser.\n")
		else:
			print("Cannot open portal. Check host and port.\n")


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
	# TODO: Add params like sampling_rate and load them from either @export vars or Speakers.gd
	var sample_rate: float = 24000.0

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
