extends Node2D

var numMush = '0'
var numMushPT = '0'

#update vars
func updateMush(num):
	numMush = str(num)
	updateValues()
func updateMushPT(num):
	print(num)
	numMushPT = str(num)
	updateValues()
	
#update text
func updateValues():
	$Mtext.text = numMush + ' [color=green]('+numMushPT+')[/color]'

	
