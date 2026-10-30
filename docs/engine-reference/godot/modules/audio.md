# Godot Audio — Quick Reference

Last verified: 2026-10-17 (4.7 changes); 2026-02-12 (rest) | Engine: Godot 4.7

## What Changed Since ~4.3 (LLM Cutoff)

No major breaking changes to the audio API in 4.4–4.6; 4.7 removes one
property and changes one default:

### 4.7 Changes
- **`AudioEffectSpectrumAnalyzer.tap_back_pos` removed**
- **`area_mask` on `AudioStreamPlayer2D`/`3D` defaults to `0`** (was layer `1`):
  `audio_bus_override` on an `Area2D`/`Area3D` stops working with the default
  mask until it is set back to layer `1` (4.7 migration guide: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.7.html)

### 4.6 Changes
- **No audio-specific breaking changes** in this release

### 4.5 Changes
- **No audio-specific breaking changes** in this release

## Current API Patterns

### Playing Audio
```gdscript
@onready var sfx_player: AudioStreamPlayer = %SFXPlayer
@onready var music_player: AudioStreamPlayer = %MusicPlayer

func play_sfx(stream: AudioStream) -> void:
    sfx_player.stream = stream
    sfx_player.play()

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
    var tween: Tween = create_tween()
    tween.tween_property(music_player, "volume_db", -80.0, fade_time)
    await tween.finished
    music_player.stream = stream
    music_player.volume_db = 0.0
    music_player.play()
```

### 3D Spatial Audio
```gdscript
@onready var audio_3d: AudioStreamPlayer3D = %AudioPlayer3D

func _ready() -> void:
    audio_3d.max_distance = 50.0
    audio_3d.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
    audio_3d.unit_size = 10.0
```

### Audio Buses
```gdscript
# Set bus volumes
AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), volume_db)
AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"), volume_db)

# Mute a bus
AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Music"), true)
```

### Object Pooling for SFX
```gdscript
# Pre-create multiple AudioStreamPlayer nodes for concurrent sounds
var _sfx_pool: Array[AudioStreamPlayer] = []

func _ready() -> void:
    for i in range(8):
        var player := AudioStreamPlayer.new()
        player.bus = &"SFX"
        add_child(player)
        _sfx_pool.append(player)

func play_pooled(stream: AudioStream) -> void:
    for player in _sfx_pool:
        if not player.playing:
            player.stream = stream
            player.play()
            return
```

### Music Stems (AudioStreamSynchronized, 4.3+)
```gdscript
# One AudioStreamSynchronized holds every stem; all stems play in lockstep.
# Add and remove layers by fading a stem's volume, never by starting it late.
# Checked against the 4.7 class reference: get/set_sync_stream_volume(index, db)
# and MethodTweener.set_trans/set_ease exist as used. The reference does not say
# whether a volume change reaches a stem that is already playing: verify in-engine.
@onready var music: AudioStreamPlayer = %Music

func fade_stem(index: int, to_db: float, seconds: float) -> void:
    var sync_stream := music.stream as AudioStreamSynchronized
    var from_db: float = sync_stream.get_sync_stream_volume(index)
    create_tween().tween_method(
        func(db: float) -> void: sync_stream.set_sync_stream_volume(index, db),
        from_db, to_db, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
```

### Section Changes (AudioStreamInteractive, 4.3+)
```gdscript
# Clips and transitions (fade mode, fade beats, sync to beat or bar) are set up
# on the AudioStreamInteractive resource in the editor; code only asks to switch.
func go_to_section(clip_name: StringName) -> void:
    # get_stream_playback() has no playback to return until play() has run.
    var playback := music.get_stream_playback() as AudioStreamPlaybackInteractive
    if playback == null:
        return
    playback.switch_to_clip_by_name(clip_name)
```

### Music Clock (BeatClock)
BeatClock (the studio autoload in addons/core) polls the playback position
every frame: `get_playback_position() + AudioServer.get_time_since_last_mix()
- output_latency`, and emits beat and bar signals. This polling is intended and
overrides the "_process() for audio timing" mistake below. Cache
`output_latency` from `AudioServer.get_output_latency()` when playback starts
rather than calling it each frame: the 4.7 class reference says the call "can be
expensive; it is not recommended to call get_output_latency() every frame".
```gdscript
var _output_latency: float = 0.0

func start(player: AudioStreamPlayer) -> void:
    _output_latency = AudioServer.get_output_latency()
    player.play()

func _song_time(player: AudioStreamPlayer) -> float:
    return player.get_playback_position() + AudioServer.get_time_since_last_mix() - _output_latency
```

## Common Mistakes
- Creating new AudioStreamPlayer nodes at runtime instead of pooling
- Not using audio buses for volume categories (Music, SFX, UI, Voice)
- Using `_process()` for audio timing instead of signals (`finished`); the
  exception is BeatClock polling the playback position every frame, which is intended
