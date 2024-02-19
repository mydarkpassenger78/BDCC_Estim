extends GameExtender
class_name EstimModuleExtender

const node_name = "estim"

func _init():
	id = "EstimModuleExtender"
	print("** Init for EstimModuleExtender")

# Get the module instance. If it's not there, create and register it
static func get_instance():
	if ! GM.main.has_node(node_name):
		print("** Installing extension for Estim")
	
		var estim = EstimModuleMain.new()
		GM.main.add_child(estim)
		estim.name=node_name
		return estim
	else:
		return GM.main.get_node(node_name)
		
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
	get_instance()
	
