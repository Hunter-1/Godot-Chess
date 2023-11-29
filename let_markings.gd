extends Node2D

var boardPosition: Vector2i

var offsetCol = 50
var offsetRow = 50
var width = 100

var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h"]

func initialize(row: int, col: int):
	$Letters.text = alphabet[col]
	boardPosition = Vector2i(col,row)
	position = _get_markingPosition()

func get_boardPosition():
	return boardPosition

func _get_markingPosition():
	return Vector2(offsetCol + boardPosition.x * width, offsetRow + boardPosition.y * width)
