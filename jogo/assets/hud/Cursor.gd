extends Sprite3D
var size
var center

#spawn outside the screen
func _ready():
	position.x = 100
	position.z = 100
	size = Vector2i(1,1)
	center = {'x' = position.x, 'z' = position.z}

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
	center.x = position.x
	if size.x > 1:
		position.x += (Globals.gridCenter*(size.x-1))
	position.z = (gridPos.y*Globals.gridSize)+Globals.gridCenter
	if size.y > 1:	
		position.z += (Globals.gridCenter*(size.y-1))
	center.z = position.z

#get center point
func getCenter():
	return center

#toggle build color
func toggleBuild(enabled):
	if enabled:
		modulate = Color(255,255,255)
	else:
		modulate = Color(255,0,0)

#change cursor size to fit building
func changeSize(newSize):
	size = newSize
	scale = Vector3(0.3*size.x, 0.3, 0.3*size.y)
