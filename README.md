# VOICEVOX Godot
This is a Godot API wrapper for [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine).

## Table of Contents
| Section													| Description														|
|-----------------------------------------------------------|-------------------------------------------------------------------|
| [Setup](#setup)											| A guide on setting up the TTS engine and running it locally.		|
| [Usage](#usage)											| Shows the gist of how it works and its examples to use.			|
| [Examples](#examples)										| Some examples on how to use it.									|
| [Standalone setup](#standalone-setup)						| Setup base on a VOICEVOX app release.								|
| [Docker setup](#docker-setup)								| Setup base on running through Docker.								|
| [Structure](#structure)									| The structure of the entire project.								|
| [Methods](#methods)										| The functions available from `VOICEVOXClient` main scene.			|
| [Main functions](#main-functions)							| The methods that abstract their purpose, e.g. *text-to-speech*.	|
| [VOICEVOX API calls](#voicevox-api-calls)					| API calls that request data and stores them, e.g. `Speakers`.		|
| [Other VOICEVOX API calls](#other-voicevox-api-calls)		| Other API calls available on VOICEVOX.							|
| [VOICEVOX User Dictionary](#voicevox-user-dictionary)		| Functions to handle user dictionary in VOICEVOX.					|
| [VOICEVOX Engine Settings](#voicevox-engine-settings)		| Functions to handle engine settings (CORS) in VOICEVOX.			|
| [Other functions](#other-functions)						| The other available functions to use.								|
| [Features](#features)										| Some stuff to make the project interesting or easier to maintain.	|
| [License](#license)										| The license of this project.										|

## Setup
This is a guide to setup this API wrapper and the speech synthesis VOICEVOX.

Firstly, here are the steps for using the `VOICEVOXClient` scripts and scenes.
1. Make a new Godot 4 project.
2. Copy the `Data` folder, `VOICEVOXClient.gd`, and `VOICEVOXClient.tscn` into the new project directory.
3. Instance `VOICEVOXClient` and add it as a child of your main scene.

After that you need a copy of VOICEVOX; either download it from [VOICEVOX releases](https://voicevox.hiroshiba.jp/), or clone [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine) from its repository. You can also follow the steps below for standalone or docker setup.

### Standalone setup
The great thing for this setup is that you only have to launch the VOICEVOX app every time you need to. The downside is that it uses its GUI.

1. Download from [VOICEVOX releases](https://voicevox.hiroshiba.jp/) based on your platform (e.g. Windows, Linux, etc.) or clone [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine) from their repository.
2. Run the executable program VOICEVOX.
3. Check http://127.0.0.1:50021/docs in a browser. If it opens the documentation then it works and you can use it on Godot.

### Docker setup
The good thing for this setup is that its headless, i.e. no GUI involved. The downside is you have to run the engine and server through Docker.

> [!NOTE]  
> While this setup is done on terminal, it is possible to setup with Godot as well via `OS.execute()`.  
> This is a headless setup; we will only use the TTS engine without their GUI.

1. Git clone [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine): `git clone https://github.com/VOICEVOX/voicevox_engine.git`
2. Run [Docker](https://www.docker.com/) image: `docker run --rm -p '127.0.0.1:50021:50021' voicevox/voicevox_engine:cpu-latest`
3. Check http://127.0.0.1:50021/docs in a browser. If it opens the documentation then it works and you can use it on Godot.

## Usage
> [!NOTE]  
> This would only work if VOICEVOX Engine runs locally at http://127.0.0.1:50021.  
> You can download [VOICEVOX releases](https://voicevox.hiroshiba.jp/) or clone [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine) and run any of them.

This is the main TTS function, the string input is handled by `post_audio_query()` and `post_synthesis()` functions to produce an audio.
```gdscript
func text_to_speech(text: String) -> void:
	post_audio_query(text)
	await request_completed
	if not audio_query.get_data().is_empty():
		post_synthesis(audio_query.get_data())
		await request_completed
	else:
		if print_stat == true:
			print("❌ text_to_speech() failed.")
```

While this is the setter for the `Speaker`'s speech settings. It sets all parameters which can be used by the `post_audio_query()` requested data after the `request_completed` signal.
```gdscript
func set_speech_settings(speaker_id: int = 3, speed: float = 1.0, pitch: float = 0.0, intonation: float = 1.0, volume: float = 2.0, pre_phoneme_duration: float = 0.1, post_phoneme_duration: float = 0.1) -> void:
	speaker = speaker_id
	speed_scale = speed
	pitch_scale = pitch
	intonation_scale = intonation
	volume_scale = volume
	pre_phoneme_length = pre_phoneme_duration
	post_phoneme_length = post_phoneme_duration
```

Together you can setup the `Speaker`'s parameters first before making a TTS request:
```gdscript
func _ready() -> void:
	set_speech_settings(3, 1.15, 0.05, 1.45, 2.0, 0.1, 0.1)
	text_to_speech("Hello world! This is voice box gee doh. It's nice to meet you!")
```

Output:
```jsonc
✓ post_audio_query() run successfully.
✓ HTTP request result code: RESULT_SUCCESS
✓ HTTP request response code: RESPONSE_OK

{
	"accent_phrases": [
		{
			"accent": 1.0,
			"is_interrogative": false,
			"moras": [
				{
					"consonant": "h",
					"consonant_length": 0.0838372334837914,
					"pitch": 5.86864805221558,
					"text": "ハ",
					"vowel": "a",
					"vowel_length": 0.0868542268872261
		// ...
		}]}]
	"intonationScale": 1.0,
	"kana": "ハ'ロオ/ワ'アルド、ディ'ス/イ'ズ/ボ'イス/ボ'ッ_クス/ギ'イ/ド'オ、イ'ッツ、ナ'イス/ツ'ウ/ミ'イト/ユ'ウ",
	// ...
}

✓ post_synthesis() run successfully.
✓ HTTP request result code: RESULT_SUCCESS
✓ HTTP request response code: RESPONSE_OK
```
Note that there are no printed output in terminal when `post_synthesis()` has `request_completed` as the received data is only played via `_play_WAV_file(data)`.

### Examples
> [!NOTE]  
> For this example, if you're following this guide and have copied the files to your Godot project, then kindly go to `VOICEVOXClient.gd` or simply click the `VOICEVOXClient.tscn` main scene and disable the `Print Data`, `Print Result`, and `Print Response` in the properties tab i.e. `Inspector`.  
>  
> By default, every requests prints the following properties to the terminal, but by turning them off we'll only print specifically when we need to.

#### Creating an object to hold data
Just as we can instance and add a VOICEVOXClient as a child to our main scene, we can also do the same to our data containers in `res://Data`.

For this example we'll create a new AudioQuery object for Zundamon.

```gdscript
extends Node

var voicevox = preload("res://VOICEVOXClient.tscn").instantiate()

func _ready() -> void:
	add_child(voicevox)

	var dialogue := "Hello, I am Zundamon! This is an example on using voice box!"
	var speaker := 3
	voicevox.post_audio_query(dialogue, speaker)
	await voicevox.request_completed

	# Here we are making a new AudioQuery to store the data we get from request and use it later
	var zundamon_query := AudioQuery.new()
	zundamon_query.data = voicevox.audio_query.get_data() # Set the received data
	zundamon_query.name = "Zundamon"
	add_child(zundamon_query, true)
	print("\nZundamon's query:\n"+JSON.stringify(zundamon_query.data, "\t")+"\n")

	# This is where we synthesize the AudioQuery into speech
	voicevox.post_synthesis(zundamon_query.get_data())
```

After instancing and adding VOICEVOXClient as a child, we used `post_audio_query()` to set an `AudioQuery` request.

Then, we made a new variable `zundamon_query` as our own new `AudioQuery` to hold the data from our request.

We just set `zundamon_query` node's `name` as "Zundamon", while set the `add_child()`'s 2nd parameter to true so that the name "Zundamon" is applied in *SceneTree* when it is added as a child.

```bash
Node                  - main scene
  ├─ VOICEVOXClient   - VOICEVOX wrapper instance
  └─ Zundamon         - the new AudioQuery
```

Then we get the actual `AudioQuery` data with `audio_query.get_data()` and set its value to "Zundamon": `zundamon_query.data = voicevox.audio_query.get_data()`.

Finally in this example we just accessed `Zundamon.data` and printed them on terminal.

```JSON
✓ post_audio_query() run successfully.

Zundamon's query:
{
	"accent_phrases": [
		{
			"accent": 1.0,
			"is_interrogative": false,
			"moras": [
				{
					"consonant": "h",
					"consonant_length": 0.0840203389525414,
					"pitch": 5.84833765029907,
					"text": "ハ",
					"vowel": "a",
					"vowel_length": 0.0927483066916466
				},
				//...
			],
		//...
		},
	],
	"intonationScale": 1.0,
	"kana": "ハ'ロオ、ア'イ/ア'ム/ズ'ンダモン、ディ'ス/イ'ズ/ア'ン/エグザ'ンプル/オ'ン/ユ'ウジング/ボ'イス/ボ'ッ_クス",
	"outputSamplingRate": 24000.0,
	"outputStereo": false,
	"pauseLength": null,
	"pauseLengthScale": 1.0,
	"pitchScale": 0.0,
	"postPhonemeLength": 0.1,
	"prePhonemeLength": 0.1,
	"speedScale": 1.0,
	"volumeScale": 2.0
}

✓ post_synthesis() run successfully.
```

For a quick test you can also check out [VOICEVOX_Godot_Test](https://github.com/UbeJelly/VOICEVOX_Godot_Test).

## Structure
This is the structure of the entire project. This only shows the relevant directories and files for this API wrapper.

```bash
# Directory
res:// (root)
  ├─ Resources                - contains the objects that hold various data.
  │   ├─ AudioQuery.gd        - stores post_audio_query() received data.
  │   ├─ Speakers.gd          - stores get_speakers() received data.
  │   └─ Synthesis.gd         - stores post_synthesis() received data.
  ├─ Scenes                   - contains all the scenes.
  │   └─ VOICEVOXClient.tscn  - is the main scene that handles http request.
  └─ Scripts                  - contains the scripts.
      └─ VOICEVOXClient.gd    - is the script of the main scene.

# Main scene
VOICEVOXClient            - the main HTTPRequest node that handles all request at http://127.0.0.1:50021.
  └─ AudioStreamPlayer    - plays the audio stream from a PackedByteArray, e.g. after a post_synthesis().
```

# Methods
These are the available functions to be used with this API wrapper.

## Main functions
These are the main functions of the main scene `VOICEVOXClient`.
- `text_to_speech(text: String)` - the Text-to-Speech function. It posts an `audio_query` and synthesizes its data with `synthesis()` function.
  - `text` is the text to synthesize to speech.
- `set_speech_settings(speaker_id: int, speed: float, pitch: float, intonation: float, volume: float, pre_phoneme_duration: float, post_phoneme_duration: float)` - modifies the settings of the `Speaker`. It affects how the synthesized speech is spoken.
  - `speaker_id` - is the id of the `Speaker`.
  - `speed` - is the speed how fast the `Speaker` talks.
  - `pitch` - is the perceived highness or lowness of a sound.
  - `intonation` - is the rise and fall of voice in speech.
  - `volume` - is the perceived loudness or intensity of a sound.
  - `pre_phoneme_duration` - is the speed how fast the `Speaker` talks.
  - `post_phoneme_duration` - is the speed how fast the `Speaker` talks.
- `set_audio_play_settings(volume: float)` - changes the settings of the `AudioStreamPlayer`. It affects how the overall audio sounds when played.
  - `volume` - is the entire volume when the audio is played.
- `_play_WAV_file(wav_data: PackedByteArray)` - plays the WAV file from synthesized speech by `post_synthesis()`.

## VOICEVOX API calls
The actual functions that handles requests and retrieves data. The data are stored to respective objects under the `Resources` directory, e.g. `post_audio_query()` → `AudioQuery.gd`.  
For more info check `Schemas` section in http://127.0.0.1:50021/docs.

These are the main functions for the most basic text-to-speech purposes.
- `get_speakers()` - requests the available `Speakers`. Receives an `Array` after `request_completed`.
- `post_audio_query(text: String, speaker_id: int)` - sets the initial values for speech synthesis query. Receives a `Dictionary` after `request_completed`.
  - `text` - is the text to be spoken by a speech synthesis query.
  - `speaker_id` - is the id of the speaker that will talk.
- `post_synthesis(audio_query_data: Dictionary)` - synthesizes the data from audio query. Receives a `PackedByteArray` after `request_completed`.
  - `audio_query_data` - is the data to synthesize speech with.

While here are the rest of functions for more configurations.
- `post_accent_phrases(text: String, speaker_id: int)` - extracts the accents of phrases from the text.
- `post_audio_query_from_preset(text: String, preset_id: int)` - creates a speech synthesis query using presets. `Presets` must not be empty. Use `post_add_preset()` to add a preset, while `get_presets()` to get an array of presets.
  - `preset_id` - is the id of a preset to use.
- `post_cancellable_synthesis(audio_query_data: Dictionary)` - synthesizes the data from audio query. Receives a `PackedByteArray` after `request_completed`. Can be cancelled.
- `post_frame_synthesis(frame_audio_query_data: Dictionary)` - synthesizes the data from frame audio query. Receives a `PackedByteArray` after `request_completed`.
- `post_mora_data(speaker_id: int, accent_phrases_data: Array)` - get phoneme length and pitch from accent phrases.
	- `accent_phrases_data` - is the returned Array from `AccentPhrases`.
- `post_mora_length(speaker_id: int, accent_phrases_data: Array)` - get phoneme lengths from accent phrases.
- `post_mora_pitch(speaker_id: int, accent_phrases_data: Array)` - get phoneme pitch from accent phrases.
- `post_morphable_targets(base_style_ids: PackedInt32Array)` - checks if characters in the engine can morph for a specified style.
	- `base_style_ids` - is an array of base style ids that can morph.
- `post_multi_synthesis(multi_audio_query_data: Array)` - synthesizes the data from multiple audio query. Receives a `PackedByteArray` after `request_completed`.
	- `multi_audio_query_data` - is an Array of multiple AudioQuery to synthesize speech from.
- `post_sing_frame_audio_query(speaker_id: int, score_data: Dictionary)` - obtains the initial values ​​for the query used for singing voice synthesis.
	- `score_data` - is the returned data from `Score`.
- `post_sing_frame_f0(speaker_id: int, score_data: Dictionary, frame_audio_query_data: Dictionary)` - get the basic frequency for each frame from queries for sheet music and singing voice synthesis.
	- `frame_audio_query_data` - is the returned data from `FrameAudioQuery`.
- `post_sing_frame_volume(speaker_id: int, score_data: Dictionary, frame_audio_query_data: Dictionary)` - get per-frame volume from queries for sheet music and vocal synthesis.
- `post_synthesis_morphing(base_speaker: int, target_speaker: int, morph_rate: float, audio_query_data: Dictionary)` - synthesize voice in two specified styles and obtain a voice morphed at a specified ratio.
	- `base_speaker` - is the id of the speaker that will be morphed.
	- `target_speaker` - is the id of another speaker to morph from.
	- `morph_rate` - is the rate of morph from 0 to 1.
	- `audio_query_data` - is the data to synthesize speech with.

## Other VOICEVOX API Calls
- `post_connect_waves(waves: PackedStringArray)` - merge multiple WAV data encoded with base64 into one.
	- `waves` - are the multiple WAV data encoded with base64.
- `post_validate_kana(text: String)` - checks whether the text follows *AquesTalk* wind transcription. If you do not follow this, error would occur.
- `post_initialize_speaker(speaker_id: int, skip_reinit: bool = false)` - initialize the specified style. Other APIs can be used without running, but the initial runtime may take some time.
	- `speaker_id` - is the id of the speaker that will talk.
	- `skip_reinit` - to skip reinitializing styles that have already been initialized.
- `is_initialized_speaker(speaker_id: int)` - returns whether the specified style has been initialized.
- `get_supported_devices()` - get a list of supported devices.
- `get_presets()` - get the preset settings used by the engine.
- `add_preset(id: int, _name: String, speaker_uuid: String, style_id: int, _speed_scale: float, _pitch_scale: float, _intonation_scale: float, _volume_scale: float, _pre_phoneme_length: float, _post_phoneme_length: float, pause_length: float, pause_length_scale: float)` - add a new preset.
- `update_preset(id: int, _name: String, speaker_uuid: String, style_id: int, _speed_scale: float, _pitch_scale: float, _intonation_scale: float, _volume_scale: float, _pre_phoneme_length: float, _post_phoneme_length: float, pause_length: float, pause_length_scale: float)` - update existing presets.
- `delete_preset(id: int)` - delete existing presets.
- `get_speaker_info(speaker_uuid: String, resource_format: String = "base64")` - returns information about the speaking character specified by UUID. Images and audio are returned in the format specified by the resource_format.
	- `resource_format` - is the format of the resource. Available values: base64, url.
- `get_singers()` - returns a list of singable characters.
- `get_singer_info(speaker_uuid: String, resource_format: String = "base64")` - returns information about the singable character specified by UUID. Images and audio are returned in the format specified by the resource_format.
- `get_version()` - get the engine version.
- `get_core_versions()` - get a list of available core versions.
- `get_engine_manifest()` - get the engine manifesto.

## VOICEVOX User Dictionary
- `get_user_dict()` - returns a list of words registered in the user dictionary. The surface form of words returns normalized forms.
- `add_user_dict_word(surface: String, pronunciation: String, accent_type: int, word_type: String = "", priority: int = 0)` - add words to the user dictionary.
	- `surface` - is the surface form of words.
	- `pronunciation` - is the pronunciation of words (katakana).
	- `accent_type` - refers to the place where the sound drops.
	- `word_type` - available values: `PROPER_NOUN`, `COMMON_NOUN`, `VERB`, `ADJECTIVE`, `SUFFIX`
	- `priority` - is a range of integers from 0 to 10). The higher the number, the higher the priority. It is recommended to specify values from 1 to 9.
- `update_user_dict_word(word_uuid: String, surface: String, pronunciation: String, accent_type: int, word_type: String = "", priority: int = 0)` - update words in the user dictionary.
	- `word_uuid` - is the UUID of the word to update.
- `delete_user_dict_word(word_uuid: String)` - delete words in the user dictionary.
- `import_user_dict(override: bool, import_dict_data: Dictionary)` - import other user dictionaries.

## VOICEVOX Engine Settings
- `open_settings()` - opens the engine settings, http://127.0.0.1:50021/setting, to the default browser if listening to the host and port.
- `update_settings(cors_policy_mode: String, allow_origin: String)` - updates the engine settings.
	- `cors_policy_mode` - either `all` or `localapps`. `localapps` limits resource sharing policies between origins to those related to app://. and localhost, while `all` allows everything. Please use this service with an understanding of the risks. Other origins can be added using the `allow_origin` option.
	- `allow_origin` - specify the allowed origins. By dividing spaces into sections, you can specify multiple items.

## Other functions
- `text_to_speech_from_preset(text: String, preset_id: int)` - same as `text_to_speech` but uses a defined preset instead.
- `open_portal()` - opens the portal (http://127.0.0.1:50021) to the default browser if listening to the host and port.
- `open_docs()` - opens the docs (http://127.0.0.1:50021/docs) to the default browser if listening to the host and port.

## Features
These are the basic features included for feasibility and maintainability.  
The descriptions also serve as documentation for the project.

Variables are exposed to the editor for ease of access and changes.  
`Console Texts` properties can be easily toggled to show or hide data and errors on terminal.  
![editor_settings_ss.png](.github/img/editor_settings_ss.png)  

Comments and notes on functions are rendered by the editor as hints.  
![function_hints_ss.png](.github/img/function_hints_ss.png)

# License
Uses MIT license. See [LICENSE.md](LICENSE.md)
