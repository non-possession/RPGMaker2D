extends Node

const SAMPLE_RATE := 22050
const MAX_INT16 := 32767.0

@export var audio_enabled := true
@export var ambient_volume_db := -27.0
@export var sfx_volume_db := -15.0
@export var memory_volume_db := -19.0

var ambient_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var photo_player: AudioStreamPlayer
var memory_player: AudioStreamPlayer
var ending_player: AudioStreamPlayer
var rng := RandomNumberGenerator.new()
var runtime_audio_available := true

func _ready() -> void:
	rng.seed = 20260505
	runtime_audio_available = DisplayServer.get_name() != "headless"
	ambient_player = _add_player("AmbientPlayer", ambient_volume_db)
	sfx_player = _add_player("SfxPlayer", sfx_volume_db)
	photo_player = _add_player("PhotoPlayer", sfx_volume_db - 1.0)
	memory_player = _add_player("MemoryPlayer", memory_volume_db)
	ending_player = _add_player("EndingPlayer", memory_volume_db - 1.0)
	if not runtime_audio_available:
		return
	ambient_player.stream = _make_stream(3.6, Callable(self, "_ambient_sample"), true)
	if audio_enabled:
		ambient_player.play()

func _exit_tree() -> void:
	for player in [ambient_player, sfx_player, photo_player, memory_player, ending_player]:
		if player == null:
			continue
		player.stop()
		player.stream = null

func play_intro() -> void:
	if not _can_play():
		return
	_play(memory_player, _make_stream(1.2, Callable(self, "_soft_rise_sample")))

func play_interaction(id: String, data: Dictionary) -> void:
	if not _can_play():
		return
	var overlay_id := str(data.get("overlay_id", ""))
	if data.get("photo_required", false):
		_play(photo_player, _make_stream(0.52, Callable(self, "_photo_sample")))
	elif overlay_id.begins_with("overlay_"):
		_play(memory_player, _make_stream(0.86, Callable(self, "_memory_sample")))
	else:
		_play(sfx_player, _make_stream(0.22, Callable(self, "_paper_sample")))
	match id:
		"A7":
			_play(memory_player, _make_stream(1.0, Callable(self, "_soft_rise_sample")))
		"A8":
			_play(sfx_player, _make_stream(0.44, Callable(self, "_drawer_sample")))
		"A12":
			_play(ending_player, _make_stream(2.4, Callable(self, "_ending_sample")))

func play_completion(id: String) -> void:
	if not _can_play():
		return
	if id == "A12":
		return
	_play(sfx_player, _make_stream(0.18, Callable(self, "_paper_sample")))

func _add_player(player_name: String, volume: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.volume_db = volume
	add_child(player)
	return player

func _can_play() -> bool:
	return audio_enabled and runtime_audio_available

func _play(player: AudioStreamPlayer, stream: AudioStreamWAV) -> void:
	player.stop()
	player.stream = stream
	player.play()

func _make_stream(duration: float, sample_func: Callable, loop := false) -> AudioStreamWAV:
	var frame_count := int(duration * SAMPLE_RATE)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	var write_index := 0
	for frame in range(frame_count):
		var t := float(frame) / float(SAMPLE_RATE)
		var sample := float(sample_func.call(t, duration))
		var int_sample := int(clamp(sample, -1.0, 1.0) * MAX_INT16)
		if int_sample < 0:
			int_sample += 65536
		bytes[write_index] = int_sample & 0xff
		bytes[write_index + 1] = (int_sample >> 8) & 0xff
		write_index += 2
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = frame_count
	return stream

func _envelope(t: float, duration: float, attack := 0.02, release := 0.08) -> float:
	var fade_in: float = clamp(t / max(attack, 0.001), 0.0, 1.0)
	var fade_out: float = clamp((duration - t) / max(release, 0.001), 0.0, 1.0)
	return min(fade_in, fade_out)

func _ambient_sample(t: float, _duration: float) -> float:
	var wind := sin(TAU * 72.0 * t) * 0.028 + sin(TAU * 117.0 * t + 0.7) * 0.018
	var dust := rng.randf_range(-0.008, 0.008)
	var slow := 0.5 + 0.5 * sin(TAU * 0.18 * t)
	return (wind + dust) * (0.35 + slow * 0.22)

func _paper_sample(t: float, duration: float) -> float:
	var noise := rng.randf_range(-1.0, 1.0) * 0.08
	var scrape := sin(TAU * (860.0 - 260.0 * t) * t) * 0.035
	return (noise + scrape) * _envelope(t, duration, 0.004, 0.08)

func _drawer_sample(t: float, duration: float) -> float:
	var grind := sin(TAU * 88.0 * t) * 0.07 + rng.randf_range(-0.04, 0.04)
	var knock := sin(TAU * 180.0 * t) * 0.06 if t < 0.1 else 0.0
	return (grind + knock) * _envelope(t, duration, 0.006, 0.12)

func _photo_sample(t: float, duration: float) -> float:
	var shutter := 0.0
	if t < 0.055:
		shutter += sin(TAU * 1250.0 * t) * 0.18
	if t > 0.08 and t < 0.17:
		shutter += sin(TAU * 420.0 * t) * 0.09
	var flash_tail := sin(TAU * 2100.0 * t) * 0.025
	return (shutter + flash_tail) * _envelope(t, duration, 0.002, 0.18)

func _memory_sample(t: float, duration: float) -> float:
	var chord := sin(TAU * 220.0 * t) * 0.045 + sin(TAU * 329.63 * t) * 0.03
	var shimmer := sin(TAU * 880.0 * t) * 0.012
	return (chord + shimmer) * _envelope(t, duration, 0.08, 0.28)

func _soft_rise_sample(t: float, duration: float) -> float:
	var rise := sin(TAU * (196.0 + 80.0 * t) * t) * 0.042
	var breath := sin(TAU * 0.65 * t) * 0.018
	return (rise + breath) * _envelope(t, duration, 0.18, 0.36)

func _ending_sample(t: float, duration: float) -> float:
	var base := sin(TAU * 174.61 * t) * 0.04
	var fifth := sin(TAU * 261.63 * t) * 0.028
	var dust := rng.randf_range(-0.004, 0.004)
	return (base + fifth + dust) * _envelope(t, duration, 0.35, 0.75)
