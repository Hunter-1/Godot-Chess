extends Area2D


var boardPosition: Vector2i

var offsetCol = 50
var offsetRow = 50
var width = 100

var piece

var white_color = Color(1,1,1)
var black_color = Color(0,0,0)

func initialize(row: int, col: int):
	boardPosition = Vector2i(row, col)
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

func set_piece(newPiece):
	add_child(newPiece)
	self.piece = newPiece


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
