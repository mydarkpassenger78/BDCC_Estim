extends Node
class_name EstimModuleMain

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var time_accu = 0.0
var player = null
var sample_hz = 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
var pulse_hz = 440.0
var phase = 0.0

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Estim Module is ready")
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = AudioStreamGenerator.new();
	player.stream.mix_rate = sample_hz # Setting mix rate is only possible before play().
	playback = player.get_stream_playback()
	fill_buffer() # Prefill, do before play() to avoid delay.
	player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_accu += delta
	if time_accu > 1.0:
		time_accu -= 1.0
		print("one second in Estim module")
	fill_buffer()
	
func fill_buffer():
	var increment = pulse_hz / sample_hz

	var to_fill = playback.get_frames_available()
	while to_fill > 0:
		playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
		phase = fmod(phase + increment, 1.0)
		to_fill -= 1	
		
