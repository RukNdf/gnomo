extends Sprite3D


#spawn outside the screen
func _ready():
	position.x = 100
	position.z = 100

#placement within the discrete virtual grid
var gridPos = Vector2i(0,0)
func update(newPos):
	#got a valid new position, calculate new valid position within the grid
	gridPos.x = newPos.position.x/Globals.gridSize
	gridPos.y = newPos.position.z/Globals.gridSize
	if gridPos.x > Globals.maxX:
		gridPos.x = Globals.maxX
	if gridPos.y > Globals.maxY:
		gridPos.y = Globals.maxY
	position.x = (gridPos.x*Globals.gridSize)+Globals.gridCenter
	position.z = (gridPos.y*Globals.gridSize)+Globals.gridCenter

#get center point
func getCenter():
	return {'x' = position.x, 'z' = position.z}
