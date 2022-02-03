extends Node2D

var active = true

func _process(_delta):
	if !active:
		return

	if $Label.get_line_count() > $Label.get_max_lines_visible():
		$Label.set_lines_skipped($Label.get_line_count() - $Label.get_max_lines_visible())

func append(text):
	if !active:
		return

	if text == "":
		return

	var current_text = $Label.get_text()
	
	var new_text = current_text
	if new_text == "":
		new_text = text
	else:
		new_text += " " + text

	# add dash-wrapping
	var characters_per_line = 14 # TODO: definitely figure out how to determine this without carefully setting the label size
	var next_wrap = characters_per_line
	for i in new_text.length():
		if i == next_wrap:
			if new_text[i - 1] != ' ' and new_text[i] != ' ':
				new_text = new_text.insert(i - 1, '-')
				new_text = new_text.insert(i, ' ')

			next_wrap += characters_per_line
			# the index of the next wrap will be offset
			# if there was a space at the current wrap
			if new_text[i] == ' ':
				next_wrap += 1

	$Label.set_text(new_text)

func deactivate():
	active = false
	visible = false
	$Label.set_text("")

func activate():
	active = true
	visible = true
	$Label.set_text("")
