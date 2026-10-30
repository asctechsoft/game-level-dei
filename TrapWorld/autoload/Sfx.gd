extends Node
## Procedurally synthesized sound effects (GDD 3.9) - jump/footstep, death
## (trap or fall), and level-complete. Generated once at startup as short WAV
## tones so the MVP needs no external/sourced audio files. Volume follows
## GameState.settings["sfx"] through a dedicated "SFX" audio bus.

const SAMPLE_RATE := 22050
const POOL_SIZE := 6

var _streams: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next_player := 0

func _ready() -> void:
	_setup_bus()
	_streams["jump"] = _tone(420.0, 780.0, 0.12, 0.5)
	_streams["step"] = _tone(160.0, 140.0, 0.045, 0.22)
	_streams["death"] = _tone(380.0, 70.0, 0.35, 0.55)
	_streams["complete"] = _chime()

	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)

func _setup_bus() -> void:
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, "SFX")
		AudioServer.set_bus_send(idx, "Master")
	set_volume(GameState.settings.get("sfx", 0.8))

func set_volume(v: float) -> void:
	var idx := AudioServer.get_bus_index("SFX")
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(max(v, 0.0001)))

func play_jump() -> void: _play("jump")
func play_step() -> void: _play("step")
func play_death() -> void: _play("death")
func play_complete() -> void: _play("complete")

func _play(key: String) -> void:
	if not _streams.has(key):
		return
	var p := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	p.stream = _streams[key]
	p.play()

## Sine tone with a linear pitch sweep (start_freq -> end_freq) and a linear
## decay envelope, for a simple retro "bleep" feel without any audio assets.
func _tone(start_freq: float, end_freq: float, duration: float, volume: float) -> AudioStreamWAV:
	var frames := int(SAMPLE_RATE * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var phase := 0.0
	for i in frames:
		var progress := float(i) / frames
		var freq: float = lerp(start_freq, end_freq, progress)
		phase += freq / SAMPLE_RATE
		var envelope := 1.0 - progress
		var sample := sin(TAU * phase) * volume * envelope
		data.encode_s16(i * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
	return _make_stream(data)

## Three ascending notes (C5-E5-G5) for reaching the door.
func _chime() -> AudioStreamWAV:
	var notes := [523.25, 659.25, 783.99]
	var note_frames := int(SAMPLE_RATE * 0.12)
	var data := PackedByteArray()
	data.resize(note_frames * notes.size() * 2)
	for n in notes.size():
		var freq: float = notes[n]
		for i in note_frames:
			var progress := float(i) / note_frames
			var envelope := 1.0 - progress * 0.7
			var sample := sin(TAU * freq * (float(i) / SAMPLE_RATE)) * 0.5 * envelope
			data.encode_s16((n * note_frames + i) * 2, int(clamp(sample, -1.0, 1.0) * 32767.0))
	return _make_stream(data)

func _make_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream
