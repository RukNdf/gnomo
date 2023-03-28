extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready():
	position.x = 100
	position.z = 100
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var gridP = Vector2i(0,0)
func update(newPos):
	if len(newPos) > 0:
		gridP.x = newPos.position.x/Globals.gridSize
		gridP.y = newPos.position.z/Globals.gridSize
		if gridP.x > Globals.maxX:
			gridP.x = Globals.maxX
		if gridP.y > Globals.maxY:
			gridP.y = Globals.maxY
		print(gridP)
		position.x = (gridP.x*Globals.gridSize)+Globals.gridCenter
		position.z = (gridP.y*Globals.gridSize)+Globals.gridCenter

func getCenter():
	return {'x' = position.x, 'z' = position.z}
