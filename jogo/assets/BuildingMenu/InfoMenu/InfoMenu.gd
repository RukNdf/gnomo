extends Node2D

func clear():
	$mush.visible = false
	$atk.visible = false

func setType(type):
	if type == 'farm':
		$gain.set
		$gain.add_theme_color_override("font_color", Color8(63, 255, 0))
		$mush.visible = true	
		$atk.visible = false
	else:
		$gain.add_theme_color_override("font_color", Color8(255, 255, 86))
		$mush.visible = false	
		$atk.visible = true

func setValues(cost, gain):
	$cost.text = '(-'+str(cost)+')'
	$gain.text = '('+str(gain)+')'
