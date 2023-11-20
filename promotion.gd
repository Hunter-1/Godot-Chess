extends Area2D

signal promotion_piece()

func initialize(color: int):
	$Queen.initialize(1,color)
	$Queen.connect("piece_clicked",self.on_click)
	$Rook.initialize(4,color)
	$Rook.connect("piece_clicked",self.on_click)
	$Bishop.initialize(2,color)
	$Bishop.connect("piece_clicked",self.on_click)
	$Knight.initialize(3,color)
	$Knight.connect("piece_clicked",self.on_click)

func on_click(color, type):
	emit_signal("promotion_piece",color,type)
