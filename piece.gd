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

var is_picked_up: bool = false
var pickup_offset: int = -50

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


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("Click"):
		if is_picked_up:
			is_picked_up = false
		is_picked_up = true
		
