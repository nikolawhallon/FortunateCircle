extends Node2D

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_SPACE:
			$SpeechProcessor.turn_off()
			$SpeechProcessor.turn_on()

func _ready():
	$WordBubble.activate()
	$SpeechProcessor.turn_on()

func _on_SpeechProcessor_processed_message_received(message):
	$WordBubble.append(message)
