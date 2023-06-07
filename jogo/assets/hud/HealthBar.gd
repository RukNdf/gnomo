extends Node3D

func _ready():
	$AnimationPlayer.play('damage')
	$AnimationPlayer.pause()


#current health based on animation
var curHealth
#actual real health
var realHealth
#max health
var maxHealth
#health changed and needs animation
var healthChanged = false
#speed at which health moves
var healthSpeedMod = 0.03
#died, stop processing inputs
var dead = false

func setHealth(health):
	curHealth = health
	maxHealth = health
	realHealth = health
	healthSpeedMod = 3.0/health
	
func damage(num):
	if !dead:
		realHealth -= num
		healthChanged = true	
	
func _process(delta):
	if healthChanged:
		if realHealth < curHealth:
			curHealth -= healthSpeedMod*delta
			if curHealth < realHealth:
				curHealth = realHealth
			animate(curHealth)
			if(curHealth <= 0):
				if !dead:
					print('dead')
					dead = true
		else:
			healthChanged = false

func animate(cur):
	$AnimationPlayer.seek(1-(cur/maxHealth), true)
