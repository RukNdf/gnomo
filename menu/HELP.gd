extends Button


func _ready():
	self.pressed.connect(self.help)

func help():
	get_tree().change_scene_to_file("res://HELP/HELP.tscn")
