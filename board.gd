extends Area2D

var Squares = []
var size: int = 8

func _ready():
	for i in range(size):
		var row = []
		for j in range(size):
			var square = preload("res://square.tscn").instantiate()
			square.initialize(i,j)
			add_child(square)
			row.append(square)
		Squares.append(row)
	add_piece(create_piece(5,0),3,4)
	add_piece(create_piece(4,1),2,5)

func add_piece(piece ,row: int, col: int):
	Squares[row][col].set_piece(piece)

func create_piece(type: int, color: int):
	var piece = preload("res://piece.tscn").instantiate()
	piece.initialize(type,color)
	return piece

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
