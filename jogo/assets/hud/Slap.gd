extends Node2D

var root
var pointTexture = load("res://jogo/assets/hud/SlapPoint.png")
var idleTexture = load("res://jogo/assets/hud/Slap.png")
func _ready():
	root = get_parent().get_parent()

func hover(on):
	if(on):
		$Sprite2D.texture = pointTexture
		rotation = 5
	else:
		rotation = 0
		$Sprite2D.texture = idleTexture

func click(building):
	rotation = 0
	$AnimationPlayer.play('slap')
	print(root)
	root.destroy(building)
