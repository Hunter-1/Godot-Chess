extends Node

var Squares = []
var size = 8

func set_squares(inputSquares):
	Squares = inputSquares

func move_piece(oldRow: int, oldCol: int, newRow: int, newCol: int):
	var color = Squares[oldRow][oldCol].get_piece().get_pieceColor()
	var captured_piece
	if Squares[newRow][newCol].get_piece() != null:
		captured_piece = remove_piece(newRow, newCol)
	add_piece(remove_piece(oldRow,oldCol),newRow, newCol)
	set_threatened_squares()
	var check = check_check(color)
	add_piece(remove_piece(newRow,newCol),oldRow, oldCol)
	add_piece(captured_piece,newRow,newCol)
	return check

func add_piece(piece ,row: int, col: int):
	Squares[row][col].set_piece(piece)

func create_piece(type: int, color: int):
	var piece = preload("res://piece.tscn").instantiate()
	piece.initialize(type,color)
	return piece

func remove_piece(row: int, col: int):
	return Squares[row][col].remove_piece()

func check_check(color: int):
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			if square.get_piece() != null:
				var piece = square.get_piece()
				if piece.get_pieceType() == 0 && piece.get_pieceColor() == color:
					if square.get_threatened_by_opposite(color):
						return true

func set_threatened_squares():
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			square.set_threatened_by_white(false)
			square.set_threatened_by_black(false)
			if square.get_piece() != null:
				var piece = square.get_piece()
				var color = piece.get_pieceColor()
				var boardPosition = square.get_boardPosition()
				for position in piece.get_legal_moves():
					if (piece.get_pieceType() != 5 || boardPosition.x != position.x):
						var squareTemp = Squares[position.y][position.x]
						if (color == 0):
							squareTemp.set_threatened_by_white(true)
						elif (color == 1):
							squareTemp.set_threatened_by_black(true)
				if piece.get_pieceType() == 5:
					var direction = piece.get_pieceColor() * -2 + 1
					var tempPosition = boardPosition + Vector2i(1,direction)
					if (tempPosition.x <= 7 && 
					tempPosition.x >= 0 &&
					tempPosition.y <= 7 && 
					tempPosition.y >= 0):
						var squareTemp = Squares[tempPosition.y][tempPosition.x]
						if (color == 0):
							squareTemp.set_threatened_by_white(true)
						elif (color == 1):
							squareTemp.set_threatened_by_black(true)
					tempPosition = boardPosition + Vector2i(-1,direction)
					if (tempPosition.x <= 7 && 
					tempPosition.x >= 0 &&
					tempPosition.y <= 7 && 
					tempPosition.y >= 0):
						var squareTemp = Squares[tempPosition.y][tempPosition.x]
						if (color == 0):
							squareTemp.set_threatened_by_white(true)
						elif (color == 1):
							squareTemp.set_threatened_by_black(true)
