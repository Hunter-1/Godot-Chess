extends Area2D

signal piece_clicked(boardPosition: Vector2i, piece)
signal move_piece(boardPosition: Vector2i)
signal capture_piece(boardPosition: Vector2i)
signal no_piece(boardPosition: Vector2i)
signal en_passant(boardPosition: Vector2i)
signal castle(boardPosition: Vector2i)

var boardPosition: Vector2i

var offsetCol = 50
var offsetRow = 50
var width = 100

var piece

var white_color = Color(211 / 255.0, 198 / 255.0, 174 / 255.0, 255 / 255.0)
var black_color = Color(83 / 255.0, 65 / 255.0, 53 / 255.0, 255 / 255.0)

var is_pickable: bool = false
var is_en_passant: bool = false
var castle_count: int = 0
var is_second_pick: bool = false

var threatened_by_white: bool = false
var threatened_by_black: bool = false

var active: bool = true
var turn_count: int = 0

func initialize(row: int, col: int):
	boardPosition = Vector2i(col,row)
	position = _get_squarePosition()

# Called when the node enters the scene tree for the first time.
func _ready():
	var sum = boardPosition.x + boardPosition.y
	if sum % 2 == 0:
		$Polygon2D.color = black_color
	else:
		$Polygon2D.color = white_color

func get_boardPosition():
	return boardPosition

func _get_squarePosition():
	return Vector2(offsetCol + boardPosition.x * width, offsetRow + 7*width - boardPosition.y * width)

func get_piece():
	return piece

func set_piece(newPiece):
	add_child(newPiece)
	self.piece = newPiece

func remove_piece():
	remove_child(piece)
	var pieceToReturn = piece
	piece = null
	return pieceToReturn

func set_is_second_pick(boolean: bool):
	is_second_pick = boolean

func set_is_en_passant(boolean: bool):
	is_en_passant = boolean

func set_castle_count(number: int):
	castle_count = number

func set_is_pickable(boolean: bool):
	is_pickable = boolean
	$Selection_Square.visible = is_pickable

func set_active(boolean: bool):
	active = boolean

func set_threatened_by_white(boolean:bool):
	threatened_by_white = boolean

func set_threatened_by_black(boolean:bool):
	threatened_by_black = boolean

func increment_turn_count():
	turn_count += 1

func set_turn_count(number: int):
	turn_count = number

func get_threatened_by_white():
	return threatened_by_white

func get_threatened_by_black():
	return threatened_by_black

func get_threatened_by_opposite(color: int):
	if color == 0:
		return threatened_by_black
	elif color == 1:
		return threatened_by_white
	return false

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click") && active:
		if !is_second_pick && piece != null && turn_count % 2 == piece.get_pieceColor():
			piece.set_is_picked_up(true)
			emit_signal("piece_clicked",boardPosition,piece)
		else:
			if (!is_pickable):
				emit_signal("no_piece",boardPosition)
			elif (piece != null):
				emit_signal("capture_piece",boardPosition)
			elif (is_en_passant):
				emit_signal("en_passant",boardPosition)
			elif (castle_count > 0):
				emit_signal("castle", boardPosition, castle_count)
			else:
				emit_signal("move_piece",boardPosition)


