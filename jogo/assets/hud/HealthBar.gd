extends Node3D


func _ready():
	$AnimationPlayer.play('damage')
	$AnimationPlayer.pause()


var max
func move(cur):
	print(cur/max)
	$AnimationPlayer.seek(1-(cur/max), true)
