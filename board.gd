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
	add_piece(3,4)

func add_piece(row: int, col: int):
	var piece = preload("res://piece.tscn").instantiate()
	Squares[row][col].set_piece(piece)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
