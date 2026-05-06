extends SceneTree

const AudioControllerScript = preload("res://scripts/audio_controller.gd")

const SAMPLE_SPECS := [
	{"name": "ambient", "duration": 3.6, "method": "_ambient_sample", "peak_limit": 0.075, "rms_limit": 0.032},
	{"name": "paper", "duration": 0.22, "method": "_paper_sample", "peak_limit": 0.145, "rms_limit": 0.05},
	{"name": "drawer", "duration": 0.44, "method": "_drawer_sample", "peak_limit": 0.17, "rms_limit": 0.065},
	{"name": "photo", "duration": 0.52, "method": "_photo_sample", "peak_limit": 0.22, "rms_limit": 0.075},
	{"name": "memory", "duration": 0.86, "method": "_memory_sample", "peak_limit": 0.095, "rms_limit": 0.04},
	{"name": "soft_rise", "duration": 1.2, "method": "_soft_rise_sample", "peak_limit": 0.08, "rms_limit": 0.035},
	{"name": "ending", "duration": 2.4, "method": "_ending_sample", "peak_limit": 0.09, "rms_limit": 0.04},
]

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var audio := Node.new()
	audio.name = "AudioControllerUnderTest"
	audio.set_script(AudioControllerScript)
	root.add_child(audio)
	await process_frame
	_assert(audio.ambient_volume_db <= -24.0, "ambient volume stays quiet")
	_assert(audio.sfx_volume_db <= -14.0, "sfx volume stays below dialogue-safe ceiling")
	_assert(audio.memory_volume_db <= -17.0, "memory volume stays below dialogue-safe ceiling")
	for spec in SAMPLE_SPECS:
		_check_sample(audio, spec)
	audio.queue_free()
	await process_frame
	if failures.is_empty():
		print("AUDIO_SAFETY_SMOKE_TEST_OK")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _check_sample(audio: Node, spec: Dictionary) -> void:
	var stream: AudioStreamWAV = audio.call("_make_stream", float(spec["duration"]), Callable(audio, str(spec["method"])))
	var metrics := _pcm_metrics(stream.data)
	_assert(metrics["peak"] <= float(spec["peak_limit"]), "%s peak %.4f <= %.4f" % [spec["name"], metrics["peak"], spec["peak_limit"]])
	_assert(metrics["rms"] <= float(spec["rms_limit"]), "%s rms %.4f <= %.4f" % [spec["name"], metrics["rms"], spec["rms_limit"]])

func _pcm_metrics(bytes: PackedByteArray) -> Dictionary:
	var peak := 0.0
	var sum_squares := 0.0
	var count := int(bytes.size() / 2)
	for index in range(count):
		var lo := int(bytes[index * 2])
		var hi := int(bytes[index * 2 + 1])
		var value := lo | (hi << 8)
		if value >= 32768:
			value -= 65536
		var sample: float = abs(float(value) / 32767.0)
		peak = max(peak, sample)
		sum_squares += sample * sample
	var rms := sqrt(sum_squares / max(1.0, float(count)))
	return {"peak": peak, "rms": rms}

func _assert(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
