extends Node2D


func selectMush():
	get_parent().select('mush')
	
func selectTower():
	get_parent().select('tower')

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
