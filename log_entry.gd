extends Node

# 0 Move
# 1 Capture
# 2 Castle

var pieceSymbol = ["K","Q","B","N","R",""]
var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]

var moveType: int

var color: int
var pieceType: int

var oldPosition: Vector2i
var newPosition: Vector2i

var castle_count: int

var check: bool
var checkmate: bool

func print_string():
	var output = ""
	if moveType == 0 || moveType == 1:
		output += pieceSymbol[pieceType]
		output += alphabet[oldPosition.x]
		output += str(oldPosition.y + 1)
		if moveType == 0:
			output += "-"
		elif moveType == 1:
			output += "x"
		output += alphabet[newPosition.x]
		output += str(newPosition.y + 1)
	if moveType == 2:
		for i in range(castle_count):
			output += "O-"
		output = output.left(output.length() - 1)
	if check:
		output += "+"
	if checkmate:
		output += "#"
	return output

func create_entry(moveType: int,
	color:int,
	pieceType:int,
	oldPosition: Vector2i,
	newPosition: Vector2i,
	castle_count:int,
	check: bool,
	checkmate: bool):
	self.moveType = moveType
	self.color = color
	self.pieceType = pieceType
	self.oldPosition = oldPosition
	self.newPosition = newPosition
	self.castle_count = castle_count
	self.check = check
	self.checkmate = checkmate

func get_moveType(): 
	return moveType

func get_color():
	return color

func get_pieceType():
	return pieceType

func get_oldPosition():
	return oldPosition

func get_newPosition():
	return newPosition

func get_check():
	return check

func get_checkmate():
	return checkmate
