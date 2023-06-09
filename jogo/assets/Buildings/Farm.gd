extends Building

############
# Init
############
var produces
func init():
	size = Vector2i(1,1)
	group = "farms"
	dead = false
	cost = 10
	produces = 5

#leave scene 
func leave(anim):
	if anim == 'die':
		get_parent().remove(self, true)
