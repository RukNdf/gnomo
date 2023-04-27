extends Node3D

func _ready():
	$AnimationPlayer.play('damage')
	$AnimationPlayer.pause()


var max
var real
func move(cur):
	$AnimationPlayer.seek(1-(cur/max), true)
