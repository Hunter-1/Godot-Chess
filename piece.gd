extends Area2D

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

func initialize(type: int, color: int):
	pieceType = type
	pieceColor = color

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.frame = pieceType + (pieceColor * 6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
