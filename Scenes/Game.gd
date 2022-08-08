extends Node

var rng = RandomNumberGenerator.new()

var on_button = false
var attack_phase = false

var riddle_taunts = [
	"Hey could you hurry it up? We don't have all day you know.",
	"I'll bet you can't get this one, no one can get this one!",
	"Are you sure you are up to the challenge? You kind of look like a wimp to me."
]
var riddle_taunts_index = 0

var attack_phase_taunt = "There's no way you'll make it past the Slooms, just give up!"
var idle_taunt = "You'll fail at this game for sure!"

var riddle_projectiles = [
	"res://Scenes/Diamond.tscn",
	"res://Scenes/Pan.tscn",
	"res://Scenes/SaltyPepper.tscn"
]
var riddle_hints = [
	"This one was a catch phrase in Disney's Aladdin!",
	"This was the name of a chapter in The Hobbit!",
	"One day my hair might turn this color."
]
var riddle_solutions = [
	"diamond in the rough",
	"out of the frying pan and into the fire",
	"salt and pepper"
]
var riddle_hints_index = 0

var attack_phase_hint = "Repeat the answer to defeat the Slooms!"
var idle_hint = "Step right up and answer the riddles for points! I'll give you hints!"

func _input(event):
	if event is InputEventKey and event.pressed:
		# this is just for quick debugging
		if event.scancode == KEY_SPACE:
			if on_button and not attack_phase:
				attack_phase = true
				$AttackPhaseTimer.start()
				$OodleboopSpeech.text = attack_phase_hint
				$LumminsSpeech.text = attack_phase_taunt
			elif on_button and attack_phase:
				var slooms = get_tree().get_nodes_in_group("Sloom")
				for sloom in slooms:
					var projectile = load(riddle_projectiles[riddle_hints_index]).instance()
					projectile.position = $Player.position
					projectile.direction = (sloom.position - $Player.position).normalized()
					add_child(projectile)
					#sloom.destroy()
					break

func _ready():
	$OodleboopSpeech.text = idle_hint
	$LumminsSpeech.text = idle_taunt
	rng.randomize()
	$DeepgramInstance.initialize("482b1489c862cce77b711a45cadc413c4d7c9c3f")

func _on_LumminsSpeechTimer_timeout():
	if on_button and not attack_phase:
		if riddle_taunts_index + 1 < riddle_taunts.size():
			riddle_taunts_index += 1
		else:
			riddle_taunts_index = 0
		$LumminsSpeech.text = riddle_taunts[riddle_taunts_index]

func _on_Button_area_entered(area):
	if area.is_in_group("PlayerFeet"):
		$Button.pressed()
		on_button = true
		if not attack_phase:
			$OodleboopSpeech.text = riddle_hints[riddle_hints_index]
			$LumminsSpeech.text = riddle_taunts[riddle_taunts_index]

func _on_Button_area_exited(area):
	if area.is_in_group("PlayerFeet"):
		$Button.unpressed()
		on_button = false
		if not attack_phase:
			$OodleboopSpeech.text = idle_hint
			$LumminsSpeech.text = idle_taunt

func _on_SloomSpawnTimer_timeout():
	if attack_phase:
		var sloom = load("res://Scenes/Sloom.tscn").instance()
		var spawn_x = 200.0
		if rng.randf() > 0.5:
			spawn_x = -200.0
		var spawn_y = 120.0
		sloom.position = Vector2(spawn_x, spawn_y)
		add_child(sloom)

func _process(_delta):
	var slooms = get_tree().get_nodes_in_group("Sloom")
	for sloom in slooms:
		sloom.destination = $Player.position

func _on_AttackPhaseTimer_timeout():
	if attack_phase:
		var slooms = get_tree().get_nodes_in_group("Sloom")
		for sloom in slooms:
			sloom.destroy()

		if riddle_hints_index + 1 < riddle_taunts.size():
			riddle_hints_index += 1
		else:
			riddle_hints_index = 0

		attack_phase = false
		if on_button:
			$OodleboopSpeech.text = riddle_hints[riddle_hints_index]
			$LumminsSpeech.text = riddle_taunts[riddle_taunts_index]
		else:
			$OodleboopSpeech.text = idle_hint
			$LumminsSpeech.text = idle_taunt

func _on_DeepgramInstance_message_received(message):
	var message_json = JSON.parse(message)
	if message_json.error == OK:
		if typeof(message_json.result) == TYPE_DICTIONARY:
			if message_json.result.has("is_final"):
				if message_json.result["is_final"] == true:
					var transcript = message_json.result["channel"]["alternatives"][0]["transcript"]
					print(transcript)
					
					if transcript.count(riddle_solutions[riddle_hints_index]):
						if on_button and not attack_phase:
							attack_phase = true
							$AttackPhaseTimer.start()
							$OodleboopSpeech.text = attack_phase_hint
							$LumminsSpeech.text = attack_phase_taunt
						elif on_button and attack_phase:
							var slooms = get_tree().get_nodes_in_group("Sloom")
							for sloom in slooms:
								var projectile = load(riddle_projectiles[riddle_hints_index]).instance()
								projectile.position = $Player.position
								projectile.direction = (sloom.position - $Player.position).normalized()
								add_child(projectile)
								#sloom.destroy()
								break
	else:
		print("Failed to parse Deepgram message!")
