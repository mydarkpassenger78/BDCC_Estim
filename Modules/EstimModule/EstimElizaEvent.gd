extends EventBase
class_name EstimElizaEvent

func _init():
	id = "EstimElizaTalkEvent"

func registerTriggers(es):
	es.addTrigger(self, Trigger.TalkingToNPC, "eliza")
	es.addTrigger(self, Trigger.SceneAndStateHook, ["IntroMedical","sit"])
	
func run(_triggerID, _args):
	addButtonUnlessLate("Estim", "Set up the estim equipment", "estimsetup")

func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "estimsetup"):
		runScene("EstimSetupScene")
