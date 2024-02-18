extends Node
class_name EstimModuleMain

# Constants
const sample_hz = 22050.0 # Keep the number of samples to mix low, GDScript is not super fast.

# Variables
var player = null
var position_a = 0.0
var position_b = 0.0
var freq_a = 0.0
var freq_b = 0.0
var ampl_a = 0.0
var ampl_b = 0.0
var phase_a = 0.0
var phase_b = 0.0
var pain_pulse_a = 0
var pain_pulse_b = 0
var pain_wait_a = 0.0
var pain_wait_b = 0.0

# settings
var freq_pain = 50.0
var duration_pain = 1.0 / 20.0
var freq_min = 100
var freq_max = 250
var ampl_min = 0.5
var ampl_max = 1.0
var pain_min = 0.7
var pain_max = 1.0
var calib_ampl = 1.0

enum EstimMode { Calib, Pleasure, Pain}

# changed depending on context
var current_mode = EstimMode.Calib
var duration_a = 1.0
var duration_b = 1.0
var freq_a_min = 0.0
var freq_a_incr = 0.0
var freq_b_min = 0.0
var freq_b_incr = 0.0
var ampl_a_min = 0.0
var ampl_a_incr = 0.0
var ampl_b_min = 0.0
var ampl_b_incr = 0.0
var ampl_pain = 1.0
var pain_ampl_a = 0.0
var pain_ampl_b = 0.0
var pain_wait_min = 0.0
var pain_wait_max = 0.0

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Estim Module is ready")
	player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = AudioStreamGenerator.new();
	player.stream.mix_rate = sample_hz # Setting mix rate is only possible before play().
	playback = player.get_stream_playback()
	update_pleasure(2.0, 1.0, 3.0, 1.0)
	fill_buffer(0.0) # Prefill, do before play() to avoid delay.
	player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fill_buffer(delta)

# Update signal generation in pleasure mode. upd_duration is the pulse duration in seconds, and upd_ampl
#  is the amplitude from 0.0 (minimum) to 1.0 (maximum)
func update_pleasure(upd_duration_a, upd_ampl_a, upd_duration_b, upd_ampl_b):
	
	current_mode = EstimMode.Pleasure
	duration_a = upd_duration_a
	position_a = 2 * duration_a  # forces to begin a new ramp
	freq_a_min = freq_min
	freq_a_incr = (freq_max - freq_min) / upd_duration_a
	var sig_ampl = (ampl_min + (ampl_max - ampl_min) * upd_ampl_a) / 2
	ampl_a_min = sig_ampl
	ampl_a_incr = sig_ampl / upd_duration_a

	duration_b = upd_duration_b
	position_b = 2 * duration_b  # forces to begin a new ramp
	freq_b_min = freq_min
	freq_b_incr = (freq_max - freq_min) / upd_duration_b
	sig_ampl = (ampl_min + (ampl_max - ampl_min) * upd_ampl_b) / 2
	ampl_b_min = sig_ampl
	ampl_b_incr = sig_ampl / upd_duration_b

# Update signal generation in pain mode. upd_wait_min/max is the minimum and maximum time between
# pulses, and upd_ampl amplitude from 0.0 (minimum) to 1.0 (maximum)
func update_pain(upd_wait_min, upd_wait_max, upd_ampl_a, upd_ampl_b):
	
	current_mode = EstimMode.Pain
	
	pain_pulse_a = 0
	pain_pulse_b = 0

	var sig_ampl = (pain_min + (pain_max - pain_min) * upd_ampl_a)
	pain_ampl_a = sig_ampl
	sig_ampl = (pain_min + (pain_max - pain_min) * upd_ampl_b)
	pain_ampl_b = sig_ampl
	
	pain_wait_min = upd_wait_min
	pain_wait_max = upd_wait_max
	
	pain_wait_a = rand_range(pain_wait_min, pain_wait_max)
	pain_wait_b = rand_range(pain_wait_min, pain_wait_max)

func update_calib(upd_calib_ampl, upd_ramp_up_time):
	
	current_mode = EstimMode.Calib
	
	calib_ampl = upd_calib_ampl
	
	ampl_a_min = 0.0
	ampl_b_min = 0.0
	
	ampl_a_incr = calib_ampl / upd_ramp_up_time
	ampl_b_incr = calib_ampl / upd_ramp_up_time
	
func fill_buffer(delta):
	# update current frequencies and amplitudes
	freq_a += freq_a_incr * delta
	freq_b += freq_b_incr * delta
	ampl_a += ampl_a_incr * delta
	ampl_b += ampl_b_incr * delta
	position_a += delta
	position_b += delta

	# see if we need to reset frequencies and amplitudes to a new pulse
	if position_a > duration_a:
		position_a = 0
		freq_a = freq_a_min
		ampl_a = ampl_a_min

	if position_b > duration_b:
		position_b = 0
		freq_b = freq_b_min
		ampl_b = ampl_b_min

	# prepare signal generation
	var increment_a = freq_a / sample_hz * TAU
	var increment_b = freq_b / sample_hz * TAU

	# generate signal
	var to_fill = playback.get_frames_available()
	while to_fill > 0:
		playback.push_frame(Vector2(sin(phase_a) * ampl_a, sin(phase_b) * ampl_b )) # Audio frames are stereo.
		phase_a = fmod(phase_a + increment_a, TAU)
		phase_b = fmod(phase_b + increment_b, TAU)
		to_fill -= 1
