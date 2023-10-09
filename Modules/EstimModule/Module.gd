extends Module

class_name EstimModule

var sample_hz = 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.
var pulse_hz = 440.0
var phase = 0.0

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

var deltamessage = 0.0

func getFlags():
	return {
		# Esrtim module
		"LustMinVolume": flag(FlagType.Number),
	}

func _init():
	id = "EstimModule"
	author = "DarkPassenger"
	
	scenes = [
		]
	characters = [
	]
	items = []
	events = [
		"res://Modules/EstimModule/EstimElizaEvent.gd"
	]
	gameExtenders = [
		"res://Modules/EstimModule/EstimModuleExtender.gd"
	]

# Called when the node enters the scene tree for the first time.
#func _ready():
#	print("running ready estim")
#	GM.main.pc.stream.mix_rate = sample_hz # Setting mix rate is only possible before play().
#	playback = GM.main.pc.get_stream_playback()
#	_fill_buffer() # Prefill, do before play() to avoid delay.
#	GM.main.pc.play()

#func _process(delta):
#	_fill_buffer()
#	deltamessage += delta
#	if deltamessage >= 1.0:
#		deltamessage -= 1.0;
#		print("process estim")


#func _fill_buffer():
#	var increment = pulse_hz / sample_hz
#
#	var to_fill = playback.get_frames_available()
#	while to_fill > 0:
#		playback.push_frame(Vector2.ONE * sin(phase * TAU)) # Audio frames are stereo.
#		phase = fmod(phase + increment, 1.0)
#		to_fill -= 1
