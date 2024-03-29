extends Building

############
# Init
############
var produces
func init():
	size = Vector2i(2,2)
	add_to_group('farms')
	group = "storage"
	dead = false
	cost = 0
	produces = 0
	buildingType = Globals.STORAGE

#leave scene 
func leave(anim):
	if anim == 'die':
		get_parent().storageDestroyed()
		get_parent().remove(self)
 

############
# Animation
############
func _ready():
	$AnimationPlayer.play('mush')
	$AnimationPlayer.pause()
	$AnimationPlayer.seek(1, true)

#max mush level
var maxMush = 300
#real mush level (target)
var realMush = 0
#current mush level
var curMush = 0
#mush changed and needs animation
var mushChanged = false
#speed at which mush moves
var mushSpeedMod = 250
	
func updtMush(num):
	print('call')
	if !dead:
		print('change')
		realMush = num
		mushChanged = true	
	
func _process(delta):
	if mushChanged:
		#print(curMush)
		if realMush < curMush:
			curMush -= mushSpeedMod*delta
			if curMush < realMush:
				curMush = realMush
			animate(curMush)
		elif realMush > curMush:
			curMush += mushSpeedMod*delta
			if curMush > realMush:
				curMush = realMush
			animate(curMush)
		else:
			mushChanged = false

func animate(cur):
	if curMush > maxMush:
		$AnimationPlayer.seek(0, true)
		mushChanged = false
	else:
		$AnimationPlayer.seek(1-(cur/float(maxMush)), true)
