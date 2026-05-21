class_name VOICEVOXClient extends HTTPRequest

enum Get {
	SPEAKERS,
	AUDIO_QUERY,
	SYNTHESIS
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
@export var print_stat: bool = true		## Show or hide the status of functions.
@export var print_data: bool = false	## Show or hide the requested data.

var url: String = "http://{host}:{port}".format(listens)
var query: int = 0

@onready var speakers := Speakers.new()
@onready var audio_query := AudioQuery.new()
@onready var audio_stream_player := $AudioStreamPlayer


func _ready() -> void:
	set_speech_settings(3, 1.15, 0.05, 1.45, 2.0, 0.1, 0.1)
	text_to_speech("Hello world! This is voice box gee doh. It's nice to meet you!")


## The Text-to-Speech function. It posts an [param audio_query] and synthesizes its data with [param synthesis()] function.
## [param text] is the text to synthesize to speech.
func text_to_speech(text: String) -> void:
	post_audio_query(text)
	await request_completed
	if not audio_query.get_data().is_empty():
		post_synthesis(audio_query.get_data())
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
func post_audio_query(text: String) -> void:
	query = Get.AUDIO_QUERY
	var params: Dictionary = { "text": text.uri_encode(), "speaker": speaker }
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

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, JSON.stringify(audio_query_data))
	if print_stat == true:
		if error == OK:
			print("✓ post_synthesis() run successfully.")
		else:
			print("❌ post_synthesis() failed.")


func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var data: Variant = null

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
				print("\n"+JSON.stringify(data_got, "\t")+"\n")
			return data_got
		else:
			if print_data == true:
				print("❌ _parse_JSON() failed. Unexpected data.")
			return {}
	else:
		if print_data == true:
			print("❌ _parse_JSON() error: ", json.get_error_message(), " in ", string, " at line ", json.get_error_line(), ".")
		return {}
