extends Node

var log_entries = []

func append_log(moveType: int, color:int, pieceType:int, oldPosition: Vector2i, newPosition: Vector2i, check: bool, checkmate: bool):
	var log_entry = preload("res://log_entry.tscn").instantiate()
	log_entry.create_entry(moveType, color, pieceType, oldPosition, newPosition, check, checkmate)
	log_entries.append(log_entry)
	print(log_entries)
