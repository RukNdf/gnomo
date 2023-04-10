extends Sprite2D

#boolean 
func activateMenu(pos):
	return get_rect().has_point(to_local(pos))
