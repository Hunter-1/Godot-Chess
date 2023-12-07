extends GutTest

var Board = preload("res://board.gd")
var _board : Board = null

func before_each():
	_board = Board.new()
	_board.init_squares()

func after_each():
	_board.free()

func test_if_8_rows():
	assert_eq(_board.Squares.size(), 8, "Squares rows should equal 8")

func test_if_rows_have_8_squares():
	var check = true
	for i in range(8):
		if _board.Squares[i].size() != 8:
			check = false
	assert_true(check,"All Rows should have 8 Items")

func test_starting_positions():
	
	_board.starting_positions()
	
