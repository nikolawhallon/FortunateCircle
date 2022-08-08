extends Area2D

func pressed():
	$Pressed.visible = true
	$Unpressed.visible = false

func unpressed():
	$Pressed.visible = false
	$Unpressed.visible = true
