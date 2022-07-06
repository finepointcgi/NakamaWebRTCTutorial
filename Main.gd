extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var username = "example"
var ReadyPlayers = []
export var ReadyUser : PackedScene = ResourceLoader.load("res://UserReady.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func ConnectToNakama():
	client = Nakama.create_client('defaultkey', "204.48.28.159", 7350,
	'http', 3, NakamaLogger.LOG_LEVEL.ERROR)
	
	var id = OS.get_unique_id()
	session = yield(client.authenticate_device_async(id, username), 'completed')
	if session.is_exception():
		print("connection has failed " + session.exception.message)
		return
	
	socket = Nakama.create_socket_from(client)
	yield(socket.connect_async(session), "completed")
	
	print("Connected!")
	StartMatchMaking()
	
func StartMatchMaking():
	OnlineMatch.min_players = 2
	OnlineMatch.max_players = 4
	OnlineMatch.client_version = 'dev'
	OnlineMatch.ice_servers = [{"urls":["stun:stun.1.google.com:19302"]}]
	OnlineMatch.use_network_relay = OnlineMatch.NetworkRelay.AUTO
	
	OnlineMatch.connect("disconnected", self, "onOnlineMatchDisconnected")
	OnlineMatch.connect("error", self, "onOnlineMatchError")
	OnlineMatch.connect("match_created", self, "onOnlineMatchMatchCreated")
	OnlineMatch.connect("match_joined", self, "onOnlineMatchMatchJoined")
	OnlineMatch.connect("matchmaker_matched", self, "onOnlineMatchMatchmakerMatched")
	OnlineMatch.connect("play_joined", self, "onOnlineMatchPlayerJoined")
	OnlineMatch.connect("play_left", self, "onOnlineMatchPlayerLeft")
	OnlineMatch.connect("player_status_changed", self, "onOnlineMatchPlayerStatusChanged")
	OnlineMatch.connect("match_ready", self, "onOnlineMatchMatchReady")
	OnlineMatch.connect("match_not_ready", self, "onOnlineMatchMatchNotReady")

	OnlineMatch.start_matchmaking(socket)
	$MatchMaking.hide()
	print("Started Matchmaking")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func onOnlineMatchMatchmakerMatched(players):
	print(players)

func onOnlineMatchPlayerStatusChanged(player, status):
	print(player, status)
	
func onOnlineMatchMatchReady(players):
	print(players)
	GameManager.Players = players
	$ConnectingScreen.hide()
	for player in players.values():
		var readyUser = ReadyUser.instance()
		readyUser.name = player.session_id
		readyUser.setUserInfo(player.username)
		$ReadyScreen/VBoxContainer.add_child(readyUser)
	
func _on_StartMatchMaking_button_down():
	username = $MatchMaking/Username.text
	ConnectToNakama()
	pass # Replace with function body.

remotesync func ready(id):
	$ReadyScreen/VBoxContainer.get_node_or_null(id).setReadyStatus("Ready")
	ReadyPlayers.append(id)
	if ReadyPlayers.size() == GameManager.Players.size():
		print("Start Game!")
		get_tree().change_scene("res://GamePlayScene.tscn")



func _on_ReadyButton_button_down():
	rpc("ready", OnlineMatch.get_my_session_id())
	pass # Replace with function body.
