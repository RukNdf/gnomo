extends Node

##############
#	Grid
###############
var size = 2
var spacing = 0.1
var maxX = 8
var maxY = 4
var gridSize = size+(spacing*2)
var gridCenter = spacing+(size/2)

##############
# Perspective
##############
var cameraOffset = {'x' = -0.2, 'z' = -0.15}

#############
#  Collision
#############
var colDelay = 0.5


############
# Placement
############
var ghostOpacity = 0.5
var blockedColor = Color(255, 0, 0)
var placementDelay = 150
