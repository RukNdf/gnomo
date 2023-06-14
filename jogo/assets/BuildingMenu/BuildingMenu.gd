extends Node2D

@onready
var curMenu = $Main
var buttonType = typeof($Main/Farm)
var keepUp = false

func select(selected):
	get_parent().select(selected)
	
func changeMenu(selected):
	curMenu.position.y = 542
	if selected == 'farms':
		curMenu = $Farms
	elif selected == 'back':
		curMenu = $Main
	elif selected == 'atk':
		curMenu = $Atk
	elif selected == 'def':
		curMenu = $Def
	curMenu.position.y = 42
	
func shortcut(num):
	var selected = curMenu.get_child(num)
	if typeof(selected) == buttonType:
		if curMenu != $Main:
			selected.emit_signal("pressed")
			changeMenu('back')
		else:
			selected.emit_signal("pressed")
	
func reset():
	changeMenu('back')
	
#move menu on hover 
var up = false
func testMenuCol(pos):
	if $colBox.activateMenu(pos):
		keepUp = false
		if !up:
			reset()
			$AnimationPlayer.pause()
			up = true
			$AnimationPlayer.play("move")
	elif !keepUp:
		if up:
			$AnimationPlayer.pause()
			up = false
			$AnimationPlayer.play_backwards()

func toggleMenu():
	if !up:
		$AnimationPlayer.pause()
		up = true
		keepUp = true
		$AnimationPlayer.play("move")
	else:
		$AnimationPlayer.pause()
		keepUp = false
		up = false
		$AnimationPlayer.play_backwards()


##############
# info menu
##############
#open info with informations from id and design of type
func openInfo(id, type):
	$InfoMenu.setType(type)
	$InfoMenu.setValues(Globals.buildingPrices[id], Globals.buildingGain[id])
	$InfoMenu.visible = true

#closes menu
func closeInfo():
	$InfoMenu.visible = false

#move menu
func _input(event):
	if event is InputEventMouse:
		$InfoMenu.position = event.position
