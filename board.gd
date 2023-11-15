extends Area2D

var letMarking = []
var numMarkings = []
var Squares = []
var size: int = 8

var is_piece_picked_up: bool = false
var picked_up_boardPosition: Vector2i
var picked_up_piece

func _ready():
	for i in range(size):
		var row = []
		for j in range(size):
			var square = preload("res://square.tscn").instantiate()
			square.initialize(i,j)
			add_child(square)
			row.append(square)
			square.connect("piece_clicked",self._on_piece_clicked)
			square.connect("move_piece", self._on_square_move_piece)
			square.connect("capture_piece", self._on_square_capture_piece)
			square.connect("no_piece", self._on_no_piece)
			var numMarking = preload("res://markings.tscn").instantiate()
			numMarking.initialize(j,-1)
			add_child(numMarking)
			var letMarking = preload("res://let_markings.tscn").instantiate()
			letMarking.initialize(9,j)
			add_child(letMarking)
			
		Squares.append(row)
	add_piece(create_piece(2,0),7,5)
	add_piece(create_piece(4,1),2,5)
	add_piece(create_piece(1,0),5,2)
	add_piece(create_piece(0,1),1,7)
	add_piece(create_piece(3,1),4,6)
	add_piece(create_piece(5,1),3,1)
	add_piece(create_piece(5,0),1,2)


func move_piece(oldRow: int, oldCol: int, newRow: int, newCol: int):
	add_piece(remove_piece(oldRow,oldCol),newRow, newCol)

func get_piece(row: int, col: int):
	return Squares[row][col].get_piece()

func remove_piece(row: int, col: int):
	return Squares[row][col].remove_piece()

func add_piece(piece ,row: int, col: int):
	Squares[row][col].set_piece(piece)

func create_piece(type: int, color: int):
	var piece = preload("res://piece.tscn").instantiate()
	piece.initialize(type,color)
	return piece

func capture_piece(oldRow: int, oldCol: int, newRow: int, newCol: int):
	remove_piece(newRow, newCol).queue_free()
	move_piece(oldRow, oldCol, newRow, newCol)

func _on_piece_clicked(boardPosition: Vector2i, piece):
	is_piece_picked_up = true
	picked_up_boardPosition = boardPosition
	picked_up_piece = piece
	get_tree().call_group("squares", "set_is_second_pick",true)
	_check_movement_squares(boardPosition,piece)

func _on_no_piece(boardPosition: Vector2i):
	if picked_up_boardPosition == boardPosition:
		picked_up_piece.set_is_picked_up(false)
		is_piece_picked_up = false
		picked_up_boardPosition = Vector2i.ZERO
		get_tree().call_group("squares", "set_is_second_pick",false)
		get_tree().call_group("squares", "set_is_pickable",false)

func _on_square_move_piece(newBoardPosition: Vector2i):
	move_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	$Log.append_log(0,picked_up_piece.get_pieceColor(),picked_up_piece.get_pieceType(),picked_up_boardPosition,newBoardPosition,false,false)
	_after_place_piece()

func _on_square_capture_piece(newBoardPosition: Vector2i):
	capture_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	$Log.append_log(1,picked_up_piece.get_pieceColor(),picked_up_piece.get_pieceType(),picked_up_boardPosition,newBoardPosition,false,false)
	_after_place_piece()

func _after_place_piece():
	picked_up_piece.set_is_picked_up(false)
	picked_up_piece.set_has_moved(true)
	is_piece_picked_up = false
	picked_up_boardPosition = Vector2i.ZERO
	get_tree().call_group("squares", "set_is_second_pick",false)
	get_tree().call_group("squares", "set_is_pickable",false)

func _check_movement_squares(boardPosition: Vector2i, piece):
	var type = piece.get_pieceType()
	var vectors = []
	var direction = -(piece.get_pieceColor() * -2 + 1)
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
					if type != 5 || i > 0:
						square.set_is_pickable(true)
				break
			if type == 5 && i == 3 && piece.get_has_moved() == false:
				square.set_is_pickable(true)
			if type != 5 || i == 0:
				square.set_is_pickable(true)
			if type == 0 || type == 3 || type == 5:
				if type == 5:
					pass
				if type == 0:
					pass
				break
			tempPosition += vector
	if type == 0:
		pass

#func _check_straight_squares(boardPosition: Vector2i):
#	for i in range(size):
#		var square = Squares[i][boardPosition.x]
#		if square.get_boardPosition() != boardPosition && square.get_piece() == null:
#			square.set_is_pickable(true)
#		square = Squares[boardPosition.y][i]
#		if square.get_boardPosition() != boardPosition && square.get_piece() == null:
#			square.set_is_pickable(true)

#func _check_diagonal_squares(boardPosition: Vector2i):
#	for i in range(size):
#		for j in range(size):
#			var square = Squares[i][j]
#			var difference = square.get_boardPosition() - boardPosition
#			if abs(difference.x) == abs(difference.y) && square.get_boardPosition() != boardPosition && square.get_piece() == null:
#				square.set_is_pickable(true)
