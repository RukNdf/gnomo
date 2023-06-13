extends Building

############
# Init
############
func init():
	size = Vector2i(1,1)
	group = "tower"
	dead = false
	cost = 20
	buildingType = Globals.TOWER

##########
# Attack
#########
#get center point
func getTargetCenter(target):
	var x = target.position.x+Globals.gridCenter
	var z = target.position.z+Globals.gridCenter
	return {'x':x, 'z':z}
#iterate through valid targets and target nearest 
func kill():
	var targets = get_tree().get_nodes_in_group("enemy")
	var tNum = len(targets)
	if tNum == 0:
		return 
	var target = 0
	var center = getTargetCenter(targets[0])
	var min = ((position.x - center.x)**2) + ((position.z - center.z)**2)
	for i in range(1, tNum):
		center = getTargetCenter(targets[i])
		var d = ((position.x - center.x)**2) + ((position.z - center.z)**2)
		if d < min:
			min = d
			target = i
	return targets[target]
