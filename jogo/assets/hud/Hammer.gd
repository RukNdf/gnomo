extends Node2D

var hitting
var hovering

func hover(on):
	hovering = on
	if on:
		$swing.play("swing")
	else:
		$swing.clear_queue()
		$swing.stop()
		rotation = 0

func click(building):
	hitting = true
	$swing.play('hit')
	$swing.queue("swing")
