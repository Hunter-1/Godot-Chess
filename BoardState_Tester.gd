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
	reset_moves()
	var check = check_check(color)
	add_piece(remove_piece(newRow,newCol),oldRow, oldCol)
	if captured_piece != null:
		add_piece(captured_piece,newRow,newCol)
	reset_moves()
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
					if square.get_threatened_by_opposite(piece.get_pieceColor()):
						return true
	return false

func run_movement_check():
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			if square.get_piece() != null:
				_check_movement_squares(square.get_boardPosition(),square.get_piece())

func _check_movement_squares(boardPosition: Vector2i, piece):
	var type = piece.get_pieceType()
	var vectors = []
	var direction = piece.get_pieceColor() * -2 + 1
	if type != 2 && type != 3 && type != 5:
		vectors.append(Vector2i(1,0))
		vectors.append(Vector2i(-1,0))
		vectors.append(Vector2i(0,1))
		vectors.append(Vector2i(0,-1))
	if type != 4 && type != 3 && type != 5:
		vectors.append(Vector2i(1,1))
		vectors.append(Vector2i(-1,1))
		vectors.append(Vector2i(1,-1))
		vectors.append(Vector2i(-1,-1))
	if type == 3:
		vectors.append(Vector2i(1,2))
		vectors.append(Vector2i(2,1))
		vectors.append(Vector2i(-1,-2))
		vectors.append(Vector2i(-2,-1))
		vectors.append(Vector2i(1,-2))
		vectors.append(Vector2i(2,-1))
		vectors.append(Vector2i(-2,1))
		vectors.append(Vector2i(-1,2))
	if type == 5:
		vectors.append(Vector2i(0,direction))
		vectors.append(Vector2i(1,direction))
		vectors.append(Vector2i(-1,direction))
		vectors.append(Vector2i(0,direction * 2))
	for i in range(0,vectors.size()):
		var vector = vectors[i]
		var tempPosition = boardPosition
		tempPosition += vector
		while (tempPosition.x <= 7 && 
		tempPosition.x >= 0 &&
		tempPosition.y <= 7 && 
		tempPosition.y >= 0):
			var square = Squares[tempPosition.y][tempPosition.x]
			if square.get_piece() != null:
				if square.get_piece().get_pieceColor() != piece.get_pieceColor():
					if type != 5 || i > 0 && i < 3:
						piece.add_legal_move(tempPosition)
				break
			if type == 5 && i == 3 && piece.get_has_moved() == false:
				var middlePosition = tempPosition - Vector2i(0,direction)
				if Squares[middlePosition.y][middlePosition.x].get_piece() == null:
					piece.add_legal_move(tempPosition)
			if type != 5 || i == 0:
				if type == 0 && square.get_threatened_by_opposite(piece.get_pieceColor()):
					break
				piece.add_legal_move(tempPosition)
			if type == 0 || type == 3 || type == 5:
				break
			tempPosition += vector


func reset_moves():
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			if square.get_piece() != null:
				var piece = square.get_piece()
				piece.empty_legal_moves()
				piece.empty_en_passant_moves()
				piece.empty_castle_moves()
	run_movement_check()
	set_threatened_squares()

func set_threatened_squares():
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			square.set_threatened_by_white(false)
			square.set_threatened_by_black(false)
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
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
