extends Area2D

signal piece_clicked(pieceColor: int, pieceType: int)

#	PieceType Codes
#	0 King
#	1 Queen
#	2 Bishop
#	3 Knight
#	4 Rook
#	5 Pawn
#
#	PieceColor Codes
#	0 White
#	1 Black

var pieceType: int
var pieceColor: int

var has_moved: bool = false
var is_picked_up: bool = false
var pickup_offset: int = -50

var legal_moves = []
var en_passant_moves = []
var castle_moves = {}

func initialize(type: int, color: int):
	pieceType = type
	pieceColor = color

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.frame = pieceType + (pieceColor * 6)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_picked_up:
		global_position = get_global_mouse_position()
		global_position += Vector2(pickup_offset, pickup_offset)

func add_legal_move(move: Vector2i):
	legal_moves.append(move)

func empty_legal_moves():
	legal_moves.clear()

func get_legal_moves():
	return legal_moves

func add_en_passant_move(move: Vector2i):
	en_passant_moves.append(move)

func empty_en_passant_moves():
	en_passant_moves.clear()

func get_en_passant_moves():
	return en_passant_moves

func add_castle_move(move: Vector2i, count: int):
	castle_moves[move] = count

func empty_castle_moves():
	castle_moves.clear()

func get_castle_moves():
	return castle_moves

func set_is_picked_up(boolean: bool):
	is_picked_up = boolean
	if !is_picked_up:
		position = Vector2.ZERO
		z_index = 1
	else:
		z_index = 2

func get_is_picked_up():
	return is_picked_up

func get_pieceType():
	return pieceType

func get_pieceColor():
	return pieceColor

func get_has_moved():
	return has_moved

func set_has_moved(boolean: bool):
	has_moved = boolean

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click"):
		emit_signal("piece_clicked",pieceColor,pieceType)
