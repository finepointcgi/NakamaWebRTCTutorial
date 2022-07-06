extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (bool) var playerControlled = false
var vector := Vector2.ZERO
var lookAtVector = 0
export var Bullet : PackedScene
signal PlayerHasDied()
var updateFrames = 6
var currentFrames = 0
var shooting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if playerControlled:
		vector = Vector2()
		if Input.is_action_pressed("ui_down"):
			vector.y +=1
		if Input.is_action_pressed("ui_up"):
			vector.y -=1
		if Input.is_action_pressed("ui_right"):
			vector.x +=1
		if Input.is_action_pressed("ui_left"):
			vector.x -=1
		vector = move_and_slide(vector * 100, Vector2.UP)
		look_at(get_global_mouse_position())
		
		if Input.is_action_just_pressed("shoot"):
			rpc("shoot", $Position2D.global_transform, name)
			pass
		currentFrames += 1
		if updateFrames <= currentFrames:
			rpc("UpdateRemotePlayers", position, rotation)
			currentFrames = 0

remotesync func shoot(shootPos, playerWhoShot):
	var bullet = Bullet.instance()
	get_tree().get_nodes_in_group("GameWorld")[0].add_child(bullet)
	bullet.transform = shootPos
	bullet.playerWhoShot = playerWhoShot


puppet func UpdateRemotePlayers(currentpos, currentRotation):
	$Tween.interpolate_property(self, "position", global_position, currentpos, .1, Tween.TRANS_LINEAR)
	$Tween.start()
	$Tween2.interpolate_property(self, "rotation", rotation, currentRotation, .1, Tween.TRANS_LINEAR)
	$Tween2.start()


remotesync func Die():
	emit_signal("PlayerHasDied")
	queue_free()
