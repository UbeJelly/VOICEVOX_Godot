class_name VOICEVOXClient extends HTTPRequest

enum Get {
	SPEAKERS,
	AUDIO_QUERY,
	SYNTHESIS
}

const listens: Dictionary = { "host": "127.0.0.1", "port": "50021" }
const headers: Dictionary = { "header": "Content-Type: application/json", "accept": "Accept: application/json" }

@export_range(0, 999) var speaker: int = 3 # Default: Zundamon's 'Normal' voice

var url: String = "http://{host}:{port}".format(listens)
var query: int = 0

@onready var speakers := Speakers.new()
@onready var audio_query := AudioQuery.new()
@onready var audio_stream_player := $AudioStreamPlayer


func _ready() -> void:
	#test_speakers()
	test_audio_query()
	await request_completed
	test_synthesis() # must test audio_query first


## Test method to use request and use speakers data.
func test_speakers() -> void:
	get_speakers()                                     # Get the array of speakers
	await request_completed                            # Wait for request_completed
	var speakers_data: Array = speakers.get_data()     # Get the actual data
	print(JSON.stringify(speakers_data, "\t")+"\n")    # Prettify on print


## Test method to use request and use audio_query data.
func test_audio_query() -> void:
	post_audio_query("Hello world! I am Zundamon. Its nice to meet you!")
	await request_completed
	var audio_query_data: Dictionary = audio_query.get_data()
	print(JSON.stringify(audio_query_data, "\t")+"\n")


func test_synthesis() -> void:
	if not audio_query.get_data().is_empty():
		post_synthesis(audio_query.get_data())
		await request_completed
	else:
		print("post_synthesis() failed. Empty AudioQuery. Call audio_query() first.\n")


## Requests the available speakers. Receives an Array after request_completed.
func get_speakers() -> void:
	query = Get.SPEAKERS
	var endpoint: String = url+"/speakers"

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_GET)
	if error == OK:
		print("get_speakers() run successfully.\n")
	else:
		print("get_speakers() failed.\n")


## Set the initial values for speech synthesis query. Receives a Dictionary after request_completed.
## [param text] is the text to be spoken by a speech synthesis query.
func post_audio_query(text: String) -> void:
	query = Get.AUDIO_QUERY
	var params: Dictionary = { "text": text.uri_encode(), "speaker": speaker }
	var endpoint: String = url+"/audio_query?text={text}&speaker={speaker}".format(params)

	var error: int = request(endpoint, [headers["accept"]], HTTPClient.METHOD_POST)
	if error == OK:
		print("post_audio_query() run successfully.\n")
	else:
		print("post_audio_query() failed.\n")


## Synthesizes the data from audio query. Receives a PackedByteArray after request_completed.
## [param audio_query_data] is the data to synthesize speech with.
func post_synthesis(audio_query_data: Dictionary) -> void:
	query = Get.SYNTHESIS
	var params: Dictionary = { "speaker": speaker }
	var endpoint: String = url+"/synthesis?speaker={speaker}".format(params)

	var error: int = request(endpoint, [headers["header"]], HTTPClient.METHOD_POST, JSON.stringify(audio_query_data))
	if error == OK:
		print("post_synthesis() run successfully.\n")
	else:
		print("post_synthesis() failed.\n")


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
				data["intonationScale"],
				data["kana"],
				data["outputSamplingRate"],
				data["outputStereo"],
				data["pauseLength"],
				data["pauseLengthScale"],
				data["pitchScale"],
				data["postPhonemeLength"],
				data["prePhonemeLength"],
				data["speedScale"],
				data["volumeScale"]
			)

		Get.SYNTHESIS:
			_play_WAV_file(body)


## Opens the docs to the default browser if listening to the host and port.
func open_docs() -> void:
	var error: int = OS.shell_open(url+"/docs".format(url))
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
			#print(JSON.stringify(data_got, "\t"))
			return data_got
		else:
			print("Unexpected data.\n")
			return {}
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", string, " at line ", json.get_error_line(), ".\n")
		return {}
