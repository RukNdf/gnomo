extends Building

############
# Init
############
var produces
func init():
	size = Vector2i(2,1)
	group = "farms"
	dead = false
	cost = 30
	produces = 12
