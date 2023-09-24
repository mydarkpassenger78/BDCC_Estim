extends GameExtender
class_name EstimModuleExtender

var installed = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init():
	id = "EstimModuleExtender"
	print("** Init for EstimModuleExtender")

func register(_GES:GameExtenderSystem):
	## Uncomment these lines to make this extender work
	_GES.register(self, ExtendGame.saveLoadData)
	#_GES.register(self, ExtendGame.npcUpdateNonBattleEffects)

func saveData():
	var data = {
		"toto": "tata"
	}
	return data
	
func loadData(data):
	print("** Estim loading data: " + data.toto)
	if ! installed:
		print("** Installing extension for Estim")
		installed = true
		
		GM.main.add_child(EstimModuleMain.new())
		
		
