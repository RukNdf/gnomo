extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

##############
#	grid
###############
var size = 2
var spacing = 0.1
var maxX = 8
var maxY = 4
var gridSize = size+(spacing*2)
var gridCenter = spacing+(size/2)

###########
# camera
###########
var cameraOffset = {'x' = -0.2, 'z' = -0.15}
