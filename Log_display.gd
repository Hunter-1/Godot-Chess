extends ScrollContainer

var entry_count: int = 0
var hbox: HBoxContainer

func _on_log_updated(text):
	var label = Label.new()
	label.text = text
	if entry_count % 2 == 0:
		hbox = HBoxContainer.new()
		var number = Label.new()
		number.text = str(entry_count / 2 + 1)
		hbox.add_child(number)
		hbox.add_child(label)
		$VBoxContainer.add_child(hbox)
		entry_count += 1
	elif entry_count % 2 == 1:
		hbox.add_child(label)
		entry_count += 1

func reset_log():
	entry_count = 0
	hbox.queue_free()
	hbox = HBoxContainer.new()
	for n in $VBoxContainer.get_children():
		self.remove_child(n)
		n.queue_free() 
	
