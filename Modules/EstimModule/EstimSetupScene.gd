extends SceneBase

var calibration_level = 0.3
var pain_level = 15
var wrong_number = 0
var pleasure_increase = 0

var estim_mod = null

const pain_wait = 0.25

func _init():
	sceneID = "EstimSetupScene"
	
func _ready():
	print("in ready scene")
	estim_mod = EstimModuleExtender.get_instance()
	
func _run():
	if(state == ""):
		saynn("[say=eliza]We need to set up your electrostimulation device. You will keep it at all times, day and night.[/say]")
		saynn("[say=eliza]How should we proceed?[/say]")

		addButton("Calibrate", "Run a calibration signal", "calibration")
		addButton("Adjust", "Adjust the different levels", "adjust")
		addButton("Setup", "Setup everything from scratch", "setup")
		addButton("Code", "Enter a code from a previous setup", "code")
		
	if(state == "calibration"):
		saynn("[say=eliza]I'm going to run a calibration signal, adjust the level of your device until it is comfortable. I'll start the signal when you say 'ready'.[/say]")
		
		addButton("Ready", "Start the calibration", "do_calibration")

	if(state == "do_calibration"):
		saynn("[say=eliza]Adjust the level of your device until it is comfortable. Say 'done' when you are happy with the level.[/say]")
		
		addButton("Done", "End the calibration", "endthescene")
		
	if(state == "adjust"):
		saynn("[say=eliza]Which one of these levels need som adjustment?[/say]")
		
		addButton("Done", "End the adjustment", "endthescene")

	if(state == "setup"):
		saynn("[say=eliza]To run the setup I will first need you to get this calibration signal and adjust the level of your device until it is comfortable. Please note that for this step the signal will be very weak so you may have to push your device a bit.[/say]")
		saynn("[say=eliza]I will start when you say 'ready'[/say]")
		
		addButton("Ready", "Start the calibration", "do_initial_calibration")

	if(state == "do_initial_calibration"):
		saynn("[say=eliza]Adjust the level of your device until it is comfortable. Say 'done' when you are happy with the level.[/say]")
		
		addButton("Done", "End the calibration", "set_max_pleasure")

	if(state == "set_max_pleasure"):
		if wrong_number == 1:
			saynn("(( Please just write a number. Try again ))")
		saynn("[say=eliza]This was the minimal pleasure level. Now I will adjust by how much this pleasure level can be increased, in %. This means that with the value 100, the maximum pleasure level will be double what you had just now.[/say]")
		
		var textBox:LineEdit = addTextbox("pleasure_increase")
		var _ok = textBox.connect("text_entered", self, "onTextBoxEnterPressed")
		
		addButton("Confirm", "Choose this level without testing", "confirm_max_pleasure")
		addButton("Test", "Test the signal level", "test_max_pleasure")

	if(state == "test_max_pleasure"):
		saynn("[say=eliza]This is a maximum pleasure level signal. If you are happy with it, say 'confirm' and if you want to adjust it again, say 'back'[/say]")
		
		addButton("Confirm", "Choose this level", "finish_test_max_pleasure")
		addButton("Back", "Readjust the level", "set_max_pleasure")

	if(state == "confirm_max_pleasure") || (state == "finish_test_max_pleasure"):
		saynn("[say=eliza]Great! Now I will adjust the pain levels. When you are ready I'll start sending a pain signal and adjust the level for minimum pain.[/say]")
		
		addButton("Ready", "Set the minimum pain level", "set_pain")
		
	if(state == "set_pain"):
		saynn("Eliza presses some buttons and looks at your reactions.")

		saynn("[say=eliza]Are you feeling pain now?[/say]")
		
		saynn("((use the buttons below to adjust the level and click on 'yes' when you start feeling some pain))")
		
		saynn("((current level %d %%))" % pain_level)
		
		addButton("-5", "reduce the level by 5", "set_pain_m5")
		addButton("-1", "reduce the level by 1", "set_pain_m1")
		addButton("+1", "increase the level by 1", "set_pain_p1")
		addButton("+5", "increase the level by 5", "set_pain_p5")

		addButton("yes", "confirm level", "set_pain_confirm")

	if(state == "set_pain_confirm"):

		saynn("[say=eliza]Great![/say]")
		
		addButton("okay", "confirm level", "endthescene")
		
	if(state == "code"):
		saynn("[say=eliza]enter the code you got from a previous setup[/say]")
		
		addButton("Done", "End the calibration", "endthescene")


func _react(_action: String, _args):
	
	if(_action == "do_calibration"):
		estim_mod.update_calib_standard(10.0)

	if(_action == "do_initial_calibration"):
		estim_mod.update_calib(calibration_level, 10.0)
		wrong_number = 0

	if(_action == "set_max_pleasure") || (_action == "finish_test_max_pleasure"):
		estim_mod.stop_signal()
		
	if(_action == "confirm_max_pleasure") || (_action == "test_max_pleasure"):
		var level =  getTextboxData("pleasure_increase")
		if level.is_valid_float():
			pleasure_increase = level.to_float()
			wrong_number = 0
			
			if (_action == "test_max_pleasure"):
				estim_mod.update_pleasure_abs(2.0, calibration_level * (pleasure_increase + 100.0) / 100.0)
		else:
			wrong_number = 1
			setState("set_max_pleasure")
			return
			
	if(_action == "set_pain"):
		pain_level = calibration_level * 50
		estim_mod.update_pain_abs(pain_wait, pain_level * 0.01)

	if(_action == "set_pain_m5"):
		pain_level -= 5
		if pain_level < 0:
			pain_level = 0
		estim_mod.update_pain_abs(pain_wait, pain_level * 0.01)
		return

	if(_action == "set_pain_m1"):
		pain_level -= 1
		if pain_level < 0:
			pain_level = 0
		estim_mod.update_pain_abs(pain_wait, pain_level * 0.01)
		return

	if(_action == "set_pain_p1"):
		pain_level += 1
		if pain_level > 100:
			pain_level = 100
		estim_mod.update_pain_abs(pain_wait, pain_level * 0.01)
		return

	if(_action == "set_pain_p5"):
		pain_level += 5
		if pain_level > 100:
			pain_level = 100
		estim_mod.update_pain_abs(pain_wait, pain_level * 0.01)
		return
		
	if(_action == "set_pain_confirm"):
		estim_mod.stop_signal()
		
	if(_action == "endthescene"):
		estim_mod.stop_signal()
		endScene()
		return

	setState(_action)
