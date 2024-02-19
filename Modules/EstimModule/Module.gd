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
		"res://Modules/EstimModule/EstimSetupScene.gd"
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
