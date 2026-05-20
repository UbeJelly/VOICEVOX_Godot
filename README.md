# VOICEVOX Godot
This is a Godot API wrapper for [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine).

Currently, it is not fully developed. I just made a repository to maintain even this early version.
I will make further changes just as I did with my other project [PokeDot](https://github.com/UbeJelly/PokeDot).

## Testing
> [!NOTE]  
> This would only work if VOICEVOX Engine runs locally at `http://127.0.0.1:50021`.  
> You can download [VOICEVOX releases](https://voicevox.hiroshiba.jp/) or clone [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine) and run any of them.

You can test this instantly with its functions `test_speakers()`, `test_audio_query()`, and `test_synthesis()`. See example on `_ready()`.

## Setup
This is a guide to setup this API wrapper and the speech synthesis VOICEVOX.

> [!NOTE]  
> While this setup is done on terminal, it is possible to setup with Godot as well via `OS.execute()`.  
> This is a headless setup; we will only use the TTS engine without their GUI.

1. Git clone [VOICEVOX Engine](https://github.com/VOICEVOX/voicevox_engine): `git clone https://github.com/VOICEVOX/voicevox_engine.git`
2. Run [Docker](https://www.docker.com/) image: `docker run --rm -p '127.0.0.1:50021:50021' voicevox/voicevox_engine:cpu-latest`
3. Check `http://127.0.0.1:50021/docs` in a browser. If it opens the documentation then it works and you can use it on Godot.

## Nodes
This is the structure of main scene `VOICEVOXClient`.

```bash
VOICEVOXClient            - the main HTTPRequest node that handles all request at http://127.0.0.1:50021.
  └─ AudioStreamPlayer    - plays the audio stream from a PackedByteArray, e.g. after speech synthesis().
```

# License
Uses MIT license. See [LICENSE.md](LICENSE.md)
