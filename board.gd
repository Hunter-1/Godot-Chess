extends Area2D



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
			square.connect("square_clicked", self._on_square_clicked)
			
		Squares.append(row)
	add_piece(create_piece(5,0),7,5)
	add_piece(create_piece(4,1),2,5)
	move_piece(2,5,2,4)

	

func move_piece(oldRow: int, oldCol: int, newRow: int, newCol: int):
	add_piece(remove_piece(oldRow,oldCol),newRow, newCol)
	print("Piece Moves from ",oldRow,oldCol," to ",newRow,newCol)

func remove_piece(row: int, col: int):
	return Squares[row][col].remove_piece()

func add_piece(piece ,row: int, col: int):
	Squares[row][col].set_piece(piece)

func create_piece(type: int, color: int):
	var piece = preload("res://piece.tscn").instantiate()
	piece.initialize(type,color)
	return piece

func _on_piece_clicked(boardPosition: Vector2i, piece):
	is_piece_picked_up = true
	picked_up_boardPosition = boardPosition
	picked_up_piece = piece
	get_tree().call_group("squares", "set_is_second_pick",true)

func _on_square_clicked(newBoardPosition: Vector2i, newPiece):
	picked_up_piece.set_is_picked_up(false)
	move_piece(
	picked_up_boardPosition.y,
	picked_up_boardPosition.x,
	newBoardPosition.y,
	newBoardPosition.x)
	is_piece_picked_up = false
	picked_up_boardPosition = Vector2i.ZERO
	get_tree().call_group("squares", "set_is_second_pick",false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
