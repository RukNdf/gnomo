extends Node

##############
#	Grid
###############
var size = 2
var spacing = 0.1
var maxX = 16
var maxY = 13
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
var blockedColor = Color(255, 0, 0, ghostOpacity)
var placementDelay = 150

##########
# Player
##########
var atkDelay = 1
var projectileDuration = 0.3
var projectileCleanupTimer = 0.05
var projectileSrcHeight = 0.5
var projectileDstHeight = 1.5

##########
# Enemy
#########
var spawnRadius = 1.5
var minESpeed = 2.5
var maxESpeed = 3.0

####################
# cursor selection
###################
enum {NOMODE, BUILDMODE, ATKMODE, EDITMODE}
var BUILDOREDIT = 1
