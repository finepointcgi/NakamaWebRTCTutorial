extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var player : PackedScene
var ReadyPlayers = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	setupGame()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func setupGame():
	for id in GameManager.Players:
		var currentPlayer = player.instance()
		currentPlayer.name = str(id)
		$PlayersSpawnUnder.add_child(currentPlayer)
		currentPlayer.set_network_master(GameManager.Players[id].peer_id)
		currentPlayer.position = get_node("SpawnPlayerPositions/" + str(GameManager.Players[id].peer_id)).position
	var myID = OnlineMatch.get_my_session_id()
	var player = $PlayersSpawnUnder.get_node(str(myID))
	player.playerControlled = true
	rpc_id(1, "finishedSetup", myID)
	
mastersync func finishedSetup(id):
	ReadyPlayers[id] = GameManager.Players[id]
	if ReadyPlayers.size() == GameManager.Players.size():
		print("start game all players are ready")

