extends Node

# 0 Move
# 1 Capture
# 2 Castle

var moveType: int

var color: int
var pieceType: int

var oldPosition: Vector2i
var newPosition: Vector2i

var check: bool
var checkmate: bool

func print_string():
	pass

func create_entry(moveType: int, color:int, pieceType:int, oldPosition: Vector2i, newPosition: Vector2i, check: bool, checkmate: bool):
	self.moveType = moveType
	self.color = color
	self.pieceType = pieceType
	self.oldPosition = oldPosition
	self.newPosition = newPosition
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
