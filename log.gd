extends Node

var log_entries = []
var display_entries = []
var has_entry: bool = false

func append_log(moveType: int, color:int, pieceType:int, oldPosition: Vector2i, newPosition: Vector2i, check: bool, checkmate: bool):
	var log_entry = preload("res://log_entry.tscn").instantiate()
	log_entry.create_entry(moveType, color, pieceType, oldPosition, newPosition, check, checkmate)
	log_entries.append(log_entry)
	has_entry = true
	display_entries.append(log_entry.print_string())
	print(log_entry.print_string())

func latest_log():
	if (log_entries.size() > 0):
		return log_entries[log_entries.size()-1]
	return null

func get_has_entry():
	return has_entry
