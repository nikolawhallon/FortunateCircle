extends Node

signal processed_message_received

func turn_on():
	var api_key = "17866c4ee8384ff60b1c6a9f663018696e73a177"

	# kill any DeepgramInstance which may have already been added
	for node in get_children():
		if node.is_in_group("DeepgramInstance"):
			node.die()

	# create a new DeepgramInstance object on the fly
	var deepgram_instance = load("res://Scenes/DeepgramIntegration/DeepgramInstance.tscn").instance()
	# add the DeepgramInstance to this object as a child node
	add_child(deepgram_instance)
	# initialize the DeepgramInstance, opening the connection with deepgram and whatnot
	deepgram_instance.initialize(api_key)
	# connect the DeepgramInstance "message_received" signal to a method of this object
	deepgram_instance.connect("message_received", self, "_on_DeepgramInstance_message_received")

func turn_off():
	# kill any DeepgramInstance which may have already been added
	for node in get_children():
		if node.is_in_group("DeepgramInstance"):
			node.die()

func _on_DeepgramInstance_message_received(message):
	var message_json = JSON.parse(message)
	if message_json.error == OK:
		if typeof(message_json.result) == TYPE_DICTIONARY:
			if message_json.result.has("is_final"):
				if message_json.result["is_final"] == true:
					# technically we could/(should?) check additionally if "alternative" exists
					var message_transcript = message_json.result["channel"]["alternatives"][0]["transcript"]
					emit_signal("processed_message_received", message_transcript)
	else:
		# TODO: this should be more like "error_message_received" or something
		emit_signal("processed_message_received", message)
