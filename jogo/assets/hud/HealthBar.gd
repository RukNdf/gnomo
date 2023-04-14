extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play('damage')
	$AnimationPlayer.pause()
	pass # Replace with function body.


var pressed = false
var b = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_1):
		if !pressed:
			pressed = true
			$AnimationPlayer.advance(0.1)
	elif Input.is_key_pressed(KEY_2):
		if !pressed:
			pressed = true
			$AnimationPlayer.advance(-0.1)
	else:
		pressed = false
	pass
