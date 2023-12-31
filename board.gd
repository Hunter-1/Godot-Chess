extends Area2D

var Squares = []
var size: int = 8

var log_entry_load = preload("res://log_entry.tscn")
var log_entry

var turn_count:int = 0

var is_piece_picked_up: bool = false
var picked_up_boardPosition: Vector2i
var picked_up_piece
var piece_to_promote_position: Vector2i
var promotion

#For Threefold Repetition
var boardState_list = {}
#For Fifty Move Limit
var fiftyMove_count = 0

var white_in_check: bool = false
var black_in_check: bool = false

var sounds = [
	preload("res://art/sound1.wav"), 
	preload("res://art/sound2.wav"), 
	preload("res://art/sound3.wav"), 
	preload("res://art/sound4.wav")
	]
		
var pick_sounds = [ 
	preload("res://art/sound6.wav"), 
	preload("res://art/sound7.wav"), 
	]

func _ready():
	for i in range(size):
		var row = []
		for j in range(size):
			var square = preload("res://square.tscn").instantiate()
			square.initialize(i,j)
			square.add_to_group("squares")
			add_child(square)
			row.append(square)
			square.connect("piece_clicked",self._on_piece_clicked)
			square.connect("move_piece", self._on_square_move_piece)
			square.connect("capture_piece", self._on_square_capture_piece)
			square.connect("no_piece", self._on_no_piece)
			square.connect("en_passant", self._on_en_passant)
			square.connect("castle", self._on_castle)
			var numMarking = preload("res://markings.tscn").instantiate()
			numMarking.initialize(j,-1)
			add_child(numMarking)
			var letMarking = preload("res://let_markings.tscn").instantiate()
			letMarking.initialize(9,j)
			add_child(letMarking)
		Squares.append(row)
	starting_positions()
	reset_moves()
	reset_moves()

func restart_game():
	if promotion != null:
		promotion.queue_free()
	is_piece_picked_up = false
	picked_up_boardPosition = Vector2i.ZERO
	picked_up_piece = null
	piece_to_promote_position = Vector2i.ZERO
	white_in_check = false
	black_in_check = false
	$End_Message.set_visible(false)
	$Log.reset_log()
	for square in get_squares():
		square.set_turn_count(0)
		square.set_active(true)
		if square.get_piece() != null:
			var piece = square.get_piece()
			square.set_piece(null)
			piece.queue_free()
	starting_positions()
	turn_count = 0
	get_tree().call_group("squares", "set_is_second_pick",false)
	get_tree().call_group("squares", "set_is_pickable",false)
	get_tree().call_group("squares", "set_is_en_passant",false)
	get_tree().call_group("squares", "set_castle_count",0)
	reset_moves()
	reset_moves()

func run_movement_check():
	for square in get_squares():
		if square.get_piece() != null:
			_check_movement_squares(square.get_boardPosition(),square.get_piece())

func set_threatened_squares():
	get_tree().call_group("squares", "set_threatened_by_white",false)
	get_tree().call_group("squares", "set_threatened_by_black",false)
	for square in get_squares():
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

func starting_positions():
	for i in range (size):
		add_piece(create_piece(5,0),1,i)
	add_piece(create_piece(4,0),0,0)
	add_piece(create_piece(4,0),0,7)
	add_piece(create_piece(3,0),0,1)
	add_piece(create_piece(3,0),0,6)
	add_piece(create_piece(2,0),0,2)
	add_piece(create_piece(2,0),0,5)
	add_piece(create_piece(1,0),0,3)
	add_piece(create_piece(0,0),0,4)
	for i in range (size):
		add_piece(create_piece(5,1),6,i)
	add_piece(create_piece(4,1),7,0)
	add_piece(create_piece(4,1),7,7)
	add_piece(create_piece(3,1),7,1)
	add_piece(create_piece(3,1),7,6)
	add_piece(create_piece(2,1),7,2)
	add_piece(create_piece(2,1),7,5)
	add_piece(create_piece(1,1),7,3)
	add_piece(create_piece(0,1),7,4)

func test_positions():
	add_piece(create_piece(2,0),7,5)
	add_piece(create_piece(4,1),2,5)
	add_piece(create_piece(1,0),5,2)
	add_piece(create_piece(0,0),0,4)
	add_piece(create_piece(4,0),0,7)
	add_piece(create_piece(4,0),0,0)
	add_piece(create_piece(5,1),3,1)
	add_piece(create_piece(5,0),1,2)
	add_piece(create_piece(0,1),6,5)

func get_squares():
	var squares = []
	for i in range(size):
		for j in range(size):
			squares.append(Squares[i][j])
	return squares

func move_piece(oldRow: int, oldCol: int, newRow: int, newCol: int):
	if Squares[newRow][newCol].get_piece() != null:
		capture_piece(oldRow,oldCol,newRow,newCol)
	else:
		add_piece(remove_piece(oldRow,oldCol),newRow, newCol)

func get_piece(row: int, col: int):
	return Squares[row][col].get_piece()

func remove_piece(row: int, col: int):
	return Squares[row][col].remove_piece()

func add_piece(piece ,row: int, col : int):
	Squares[row][col].set_piece(piece)

func create_piece(type: int, color: int):
	var piece = preload("res://piece.tscn").instantiate()
	piece.initialize(type,color)
	add_to_group("pieces")
	return piece

func capture_piece(oldRow: int, oldCol: int, newRow: int, newCol: int):
	remove_piece(newRow, newCol).queue_free()
	move_piece(oldRow, oldCol, newRow, newCol)

func _on_piece_clicked(boardPosition: Vector2i, piece):
	play_random_pick_sound()
	is_piece_picked_up = true
	picked_up_boardPosition = boardPosition
	picked_up_piece = piece
	get_tree().call_group("squares", "set_is_second_pick",true)
	var legal_moves = piece.get_legal_moves()
	var en_passant_moves = piece.get_en_passant_moves()
	var castle_moves = piece.get_castle_moves()
	for square in legal_moves:
		Squares[square.y][square.x].set_is_pickable(true)
		if en_passant_moves.has(square):
			Squares[square.y][square.x].set_is_en_passant(true)
		if castle_moves.has(square):
			Squares[square.y][square.x].set_castle_count(castle_moves[square])


func _on_no_piece(boardPosition: Vector2i):
	if picked_up_boardPosition == boardPosition:
		picked_up_piece.set_is_picked_up(false)
		is_piece_picked_up = false
		picked_up_boardPosition = Vector2i.ZERO
		get_tree().call_group("squares", "set_is_second_pick",false)
		get_tree().call_group("squares", "set_is_pickable",false)
		get_tree().call_group("squares", "set_is_en_passant",false)
		get_tree().call_group("squares", "set_castle_count",0)

func _on_square_move_piece(newBoardPosition: Vector2i):
	move_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	log_entry = log_entry_load.instantiate()
	log_entry.create_entry(picked_up_piece.get_pieceColor(),picked_up_piece.get_pieceType(),picked_up_boardPosition,newBoardPosition)
	var color = picked_up_piece.get_pieceColor()
	if picked_up_piece.get_pieceType() == 5:
		fiftyMove_count = 0
	if !_check_if_promotion(newBoardPosition):
		_after_place_piece(color)

func _on_square_capture_piece(newBoardPosition: Vector2i):
	capture_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	log_entry = log_entry_load.instantiate()
	log_entry.create_entry(picked_up_piece.get_pieceColor(),picked_up_piece.get_pieceType(),picked_up_boardPosition,newBoardPosition)
	log_entry.set_capture(true)
	fiftyMove_count = 0
	var color = picked_up_piece.get_pieceColor()
	if !_check_if_promotion(newBoardPosition):
		_after_place_piece(color)
		

func _check_if_promotion(newBoardPosition: Vector2i):
	var piece = Squares[newBoardPosition.y][newBoardPosition.x].get_piece()
	if piece.get_pieceType() == 5:
		if newBoardPosition.y == 7 - 7 * piece.get_pieceColor():
			promotion = preload("res://promotion.tscn").instantiate()
			promotion.initialize(piece.get_pieceColor())
			add_child(promotion)
			promotion.connect("promotion_piece", self._on_promote)
			piece_to_promote_position = newBoardPosition
			get_tree().call_group("squares", "set_active",false)
			promotion.position = Vector2(250,400)
			play_random_sound()
			if picked_up_piece != null:
				picked_up_piece.set_is_picked_up(false)
				picked_up_piece.set_has_moved(true)
			is_piece_picked_up = false
			picked_up_boardPosition = Vector2i.ZERO
			get_tree().call_group("squares", "set_is_pickable",false)
			return true
	return false

func _on_promote(color, type):
	remove_piece(piece_to_promote_position.y,piece_to_promote_position.x)
	add_piece(create_piece(type,color),piece_to_promote_position.y,piece_to_promote_position.x)
	log_entry.set_promotionPieceType(type)
	_after_place_piece(color)
	remove_child(promotion)
	get_tree().call_group("squares", "set_active",true)
	

func _on_en_passant(newBoardPosition: Vector2i):
	var difference = picked_up_boardPosition - newBoardPosition
	remove_piece(picked_up_boardPosition.y,picked_up_boardPosition.x - difference.x)
	move_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	log_entry = log_entry_load.instantiate()
	log_entry.create_entry(picked_up_piece.get_pieceColor(),picked_up_piece.get_pieceType(),picked_up_boardPosition,newBoardPosition)
	var color = picked_up_piece.get_pieceColor()
	log_entry.set_capture(true)
	_after_place_piece(color)
	

	

func _on_castle(newBoardPosition: Vector2i, castle_count: int):
	var difference = picked_up_boardPosition - newBoardPosition
	var direction: int = 0
	if difference.x > 0:
		direction = 1
	else:
		direction = -1
	move_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	move_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x - castle_count * direction - direction,
	newBoardPosition.y,
	newBoardPosition.x + direction)
	log_entry = log_entry_load.instantiate()
	log_entry.create_entry(picked_up_piece.get_pieceColor(),picked_up_piece.get_pieceType(),picked_up_boardPosition,newBoardPosition)
	log_entry.set_castle_count(castle_count)
	var color = picked_up_piece.get_pieceColor()
	_after_place_piece(color)
	

func _after_place_piece(color):
	play_random_sound()
	if picked_up_piece != null:
		picked_up_piece.set_is_picked_up(false)
		picked_up_piece.set_has_moved(true)
	is_piece_picked_up = false
	picked_up_boardPosition = Vector2i.ZERO
	reset_moves()
	reset_moves()
	get_tree().call_group("pieces", "empty_illegal_moves")
	picked_up_piece = null
	black_in_check = false
	white_in_check = false
	increment_turn_count()
	get_tree().call_group("squares", "set_is_second_pick",false)
	get_tree().call_group("squares", "set_is_pickable",false)
	get_tree().call_group("squares", "set_is_en_passant",false)
	get_tree().call_group("squares", "set_castle_count",0)
	check_check()
	if (color == 0):
		log_entry.set_check(black_in_check)
	elif (color == 1):
		log_entry.set_check(white_in_check)
	get_tree().call_group("pieces", "empty_illegal_moves")
	calculate_illegal_moves()
	reset_moves()
	for square in get_squares():
		if square.get_piece() != null:
			var piece = square.get_piece()
			var illegal_moves = piece.get_illegal_moves()
			for move in illegal_moves:
				piece.remove_legal_move(move)
	threefold_repetition_check()
	fiftymove_limit_check()
	test_check_stale()
	$Log.append_log(log_entry)
	reset_moves()
	for square in get_squares():
		if square.get_piece() != null:
			var piece = square.get_piece()
			var illegal_moves = piece.get_illegal_moves()
			for move in illegal_moves:
				piece.remove_legal_move(move)

func fiftymove_limit_check():
	fiftyMove_count += 1
	#fiftyMove_count checks for 100 because a full move consists of 2 player moves
	#and each player move increases this value by 1
	if fiftyMove_count == 100:
		log_entry.set_stalemate(true)
		end_message("Stalemate: Fifty Move Limit")

func threefold_repetition_check():
	var colorSymbol = ["W","B"]
	var pieceSymbol = ["K","Q","B","N","R","P"]
	var boardStateString = ""
	for square in get_squares():
		if square.get_piece() != null:
			var piece = square.get_piece()
			boardStateString += colorSymbol[piece.get_pieceColor()]
			boardStateString += pieceSymbol[piece.get_pieceType()]
		else:
			boardStateString += "-"
	if !boardState_list.has(boardStateString):
		boardState_list[boardStateString] = 0
	boardState_list[boardStateString] += 1
	if boardState_list[boardStateString] == 3:
		log_entry.set_stalemate(true)
		end_message("Stalemate: Threefold Repetition")

func test_check_stale():
	if !has_legal_moves(turn_count % 2):
		if get_check(turn_count % 2):
			var color
			if turn_count % 2 == 1:
				color = "White"
			else:
				color = "Black"
			log_entry.set_checkmate(true)
			end_message("Checkmate: " + color + " Wins!")
		else:
			log_entry.set_stalemate(true)
			end_message("Stalemate")

func end_message(message):
	get_tree().call_group("squares", "set_active",false)
	$End_Message/Polygon2D/Label.text = message
	$End_Message.set_visible(true)
	

func has_legal_moves(color:int):
	var check = false
	for square in get_squares():
		if square.get_piece() != null:
			var piece = square.get_piece()
			if piece.get_pieceColor() == color:
				var legal_moves = piece.get_legal_moves()
				if legal_moves.size() > 0:
					check = true
	return check

func calculate_illegal_moves():
	var tempSquares = Squares.duplicate(true)
	for i in range(size):
		for j in range(size):
			if tempSquares[i][j].get_piece() != null:
				var BoardPosition = tempSquares[i][j].get_boardPosition()
				var piece = tempSquares[i][j].get_piece()
				var legal_moves = piece.get_legal_moves()
				var temp_legal_moves = legal_moves.duplicate(true)
				for move in temp_legal_moves:
					var check = calculate_illegal_move(BoardPosition.y,BoardPosition.x,move.y,move.x)
					if check:
						piece.add_illegal_move(move)

func calculate_illegal_move(oldRow: int, oldCol: int, newRow: int, newCol: int):
	var color = Squares[oldRow][oldCol].get_piece().get_pieceColor()
	var captured_piece
	if Squares[newRow][newCol].get_piece() != null:
		captured_piece = remove_piece(newRow, newCol)
	var picked_up_piece = remove_piece(oldRow,oldCol)
	var has_moved = picked_up_piece.get_has_moved()
	picked_up_piece.set_has_moved(true)
	add_piece(picked_up_piece,newRow, newCol)
	reset_moves()
	var check = check_check_bool(color)
	var replace_piece = remove_piece(newRow,newCol)
	if !has_moved:
		replace_piece.set_has_moved(false)
	add_piece(replace_piece,oldRow, oldCol)
	if captured_piece != null:
		add_piece(captured_piece,newRow,newCol)
	reset_moves()
	return check

func check_check_bool(color: int):
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			if square.get_piece() != null:
				var piece = square.get_piece()
				if piece.get_pieceType() == 0 && piece.get_pieceColor() == color:
					if square.get_threatened_by_opposite(piece.get_pieceColor()):
						return true
	return false


func increment_turn_count():
	turn_count += 1
	get_tree().call_group("squares", "increment_turn_count")

func check_check():
	for square in get_squares():
		if square.get_piece() != null:
			var piece = square.get_piece()
			if piece.get_pieceType() == 0:
				var color = piece.get_pieceColor()
				if square.get_threatened_by_opposite(color):
					set_check(color,true)

func set_check(color: int, boolean: bool):
	if color == 0:
		white_in_check = boolean
	if color == 1:
		black_in_check = boolean

func get_check(color: int):
	if color == 0:
		return white_in_check
	if color == 1:
		return black_in_check

func reset_moves():
	for i in range(size):
		for j in range(size):
			var square = Squares[i][j]
			if square.get_piece() != null:
				var piece = square.get_piece()
				piece.empty_legal_moves()
				piece.empty_en_passant_moves()
				piece.empty_castle_moves()
	if picked_up_piece != null:
		picked_up_piece.empty_legal_moves()
		picked_up_piece.empty_en_passant_moves()
		picked_up_piece.empty_castle_moves()
	run_movement_check()
	set_threatened_squares()

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
				piece.add_legal_move(tempPosition)
			if type == 5 && i == 1 || i == 2 :
				if $Log.get_has_entry():
					var log_entry = $Log.latest_log()
					var difference = log_entry.get_oldPosition() - log_entry.get_newPosition()
					if (log_entry.get_pieceType() == 5 && 
					abs(difference.y) == 2):
						var middlePosition = log_entry.get_oldPosition() - Vector2i(0,direction)
						if middlePosition == tempPosition:
							piece.add_legal_move(tempPosition)
							piece.add_en_passant_move(tempPosition)
			if type == 0 || type == 3 || type == 5:
				break
			tempPosition += vector
	if type == 0 && !piece.get_has_moved():
		castle_check(boardPosition, piece)

func castle_check(boardPosition: Vector2i, piece):
	var vectors = []
	vectors.append(Vector2i(1,0))
	vectors.append(Vector2i(-1,0))
	var initSquare = Squares[boardPosition.y][boardPosition.x]
	var threatened = initSquare.get_threatened_by_opposite(piece.get_pieceColor())
	if !threatened:
		for i in range(0,vectors.size()):
			var vector = vectors[i]
			var castle_count = 0
			var tempPosition = boardPosition
			tempPosition += vector
			while (tempPosition.x <= 7 && 
			tempPosition.x >= 0 &&
			tempPosition.y <= 7 && 
			tempPosition.y >= 0):
				var square = Squares[tempPosition.y][tempPosition.x]
				if square.get_piece() != null:
					if square.get_piece().get_pieceType() != 4:
						break
					elif !square.get_piece().get_has_moved():
						tempPosition = boardPosition
						tempPosition += vector
						tempPosition += vector
						square = Squares[tempPosition.y][tempPosition.x]
						piece.add_legal_move(tempPosition)
						piece.add_castle_move(tempPosition,castle_count)
						break
				if square.get_threatened_by_opposite(piece.get_pieceColor()) && castle_count < 2:
					break
				castle_count += 1
				tempPosition += vector

func play_random_sound():
	var random_index = randi() % sounds.size()
	var sound = sounds[random_index]
	if sound:
		var audio_player = $Place_Soundeffect
		audio_player.stream = sound
		audio_player.play()
		
func play_random_pick_sound():
	var random_index2 = randi() % pick_sounds.size()
	var sound = pick_sounds[random_index2]
	if sound:
		var audio_player = $Place_Soundeffect
		audio_player.stream = sound
		audio_player.play()

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
