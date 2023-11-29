extends Node

var pieceSymbol = ["K","Q","B","N","R",""]
var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]

var capture: bool = false

var pieceColor: int
var pieceType: int
var promotionPieceType: int

var oldPosition: Vector2i
var newPosition: Vector2i

var castle_count: int = 0

var check: bool = false
var checkmate: bool = false
var stalemate: bool = false

func print_string():
	var output = ""
	if castle_count > 0:
		for i in range(castle_count):
			output += "O-"
		output = output.left(output.length() - 1)
	else:
		output += pieceSymbol[pieceType]
		output += alphabet[oldPosition.x]
		output += str(oldPosition.y + 1)
		if capture:
			output += "x"
		else:
			output += "-"
		output += alphabet[newPosition.x]
		output += str(newPosition.y + 1)
		if (promotionPieceType > 0):
			output += "="
			output += pieceSymbol[promotionPieceType]
	if checkmate:
		output += "#"
	elif stalemate:
		output += "$"
	elif check:
		output += "+"
	return output

func create_entry(color:int,type:int,old:Vector2i,new:Vector2i):
	pieceColor = color
	pieceType = type
	oldPosition = old
	newPosition = new

func get_capture(): 
	return capture

func set_capture(boolean:bool):
	capture = boolean

func get_colorType():
	return pieceColor

func set_colorType(number:int):
	pieceColor = number

func get_pieceType():
	return pieceType

func set_pieceType(number:int):
	pieceType = number

func get_oldPosition():
	return oldPosition

func set_oldPosition(position: Vector2i):
	oldPosition = position

func get_newPosition():
	return newPosition

func set_newPosition(position: Vector2i):
	newPosition = position

func get_castle_count():
	return castle_count

func set_castle_count(number:int):
	castle_count = number

func get_check():
	return check

func set_check(boolean: bool):
	check = boolean

func get_checkmate():
	return checkmate

func set_checkmate(boolean: bool):
	checkmate = boolean

func get_stalemate():
	return stalemate

func set_stalemate(boolean: bool):
	stalemate = boolean

func get_promotionPieceType():
	return promotionPieceType

func set_promotionPieceType(number: int):
	promotionPieceType = number
