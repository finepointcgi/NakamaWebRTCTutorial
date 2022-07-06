extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeToLive = 100
var playerWhoShot = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	position += transform.x * 750 * delta
	timeToLive -= delta
	if timeToLive < 0:
		queue_free()


func _on_Bullet_body_entered(body):
	if body.name != playerWhoShot:
		if is_network_master():
			body.rpc("Die")
	pass # Replace with function body.
