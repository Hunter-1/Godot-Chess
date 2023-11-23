extends Node

signal updated(text)
signal reset

var log_entries = []
var display_entries = []
var has_entry: bool = false

func append_log(log_entry):
	log_entries.append(log_entry)
	has_entry = true
	emit_signal("updated",log_entry.print_string())
	display_entries.append(log_entry.print_string())

func latest_log():
	if (log_entries.size() > 0):
		return log_entries[log_entries.size()-1]
	return null

func reset_log():
	log_entries = []
	display_entries = []
	has_entry = false
	emit_signal("reset")

func get_has_entry():
	return has_entry
