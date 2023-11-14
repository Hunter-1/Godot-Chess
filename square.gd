extends Area2D

signal piece_clicked(boardPosition: Vector2i, piece)
signal move_piece(boardPosition: Vector2i)
signal capture_piece(boardPosition: Vector2i)
signal no_piece(boardPosition: Vector2i)

var boardPosition: Vector2i

var offsetCol = 50
var offsetRow = 50
var width = 100

var piece

var white_color = Color(1,1,1)
var black_color = Color(0,0,0)

var is_pickable: bool = false
var is_second_pick: bool = false

func initialize(row: int, col: int):
	boardPosition = Vector2i(col,row)
	position = _get_squarePosition()

# Called when the node enters the scene tree for the first time.
func _ready():
	var sum = boardPosition.x + boardPosition.y
	if sum % 2 == 1:
		$Polygon2D.color = black_color
	else:
		$Polygon2D.color = white_color

func get_boardPosition():
	return boardPosition

func _get_squarePosition():
	return Vector2(offsetCol + boardPosition.x * width, offsetRow + boardPosition.y * width)

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

func set_is_pickable(boolean: bool):
	is_pickable = boolean
	$Selection_Square.visible = is_pickable

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click"):
		if !is_second_pick:
			if piece != null:
				piece.set_is_picked_up(true)
				emit_signal("piece_clicked",boardPosition,piece)
			else:
				print(boardPosition)
		else:
			if (is_pickable):
				if (piece == null):
					emit_signal("move_piece",boardPosition)
				else:
					emit_signal("capture_piece",boardPosition)
			else:
				emit_signal("no_piece",boardPosition)
