extends Node2D

@onready
var curMenu = $Main

func select(selected):
	get_parent().select(selected)
	
func changeMenu(selected):
	print(curMenu)
	curMenu.position.y = 542
	if selected == 'farms':
		curMenu = $Farms
	if selected == 'back':
		curMenu = $Main
	curMenu.position.y = 42
	
#move menu on hover 
var up = false
func testMenuCol(pos):
	if $colBox.activateMenu(pos):
		if !up:
			$AnimationPlayer.pause()
			up = true
			$AnimationPlayer.play("move")
	else:
		if up:
			$AnimationPlayer.pause()
			up = false
			$AnimationPlayer.play_backwards()
